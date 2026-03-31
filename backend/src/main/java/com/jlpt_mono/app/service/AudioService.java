package com.jlpt_mono.app.service;

import com.jlpt_mono.app.config.B2StorageProperties;
import com.jlpt_mono.app.config.AudioQueueProperties;
import com.jlpt_mono.app.config.ElevenLabsProperties;
import com.jlpt_mono.app.dto.AudioResponse;
import com.jlpt_mono.app.entity.*;
import com.jlpt_mono.app.exception.ResourceNotFoundException;
import com.jlpt_mono.app.repository.AudioCacheRepository;
import com.jlpt_mono.app.repository.AudioTaskRepository;
import com.jlpt_mono.app.repository.WordRepository;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class AudioService {

    private final AudioCacheRepository audioCacheRepository;
    private final AudioTaskRepository audioTaskRepository;
    private final WordRepository wordRepository;
    private final AudioEnqueueService audioEnqueueService;
    private final AudioQueueDispatcher audioQueueDispatcher;
    private final B2StorageClient b2StorageClient;
    private final ElevenLabsProperties elevenLabsProperties;
    private final B2StorageProperties b2StorageProperties;
    private final AudioQueueProperties audioQueueProperties;

    private static final List<AudioTaskStatus> ACTIVE_STATUSES =
            List.of(AudioTaskStatus.QUEUED, AudioTaskStatus.CLAIMED);

    public AudioService(AudioCacheRepository audioCacheRepository,
                        AudioTaskRepository audioTaskRepository,
                        WordRepository wordRepository,
                        AudioEnqueueService audioEnqueueService,
                        AudioQueueDispatcher audioQueueDispatcher,
                        B2StorageClient b2StorageClient,
                        ElevenLabsProperties elevenLabsProperties,
                        B2StorageProperties b2StorageProperties,
                        AudioQueueProperties audioQueueProperties) {
        this.audioCacheRepository = audioCacheRepository;
        this.audioTaskRepository = audioTaskRepository;
        this.wordRepository = wordRepository;
        this.audioEnqueueService = audioEnqueueService;
        this.audioQueueDispatcher = audioQueueDispatcher;
        this.b2StorageClient = b2StorageClient;
        this.elevenLabsProperties = elevenLabsProperties;
        this.b2StorageProperties = b2StorageProperties;
        this.audioQueueProperties = audioQueueProperties;
    }

    public AudioResponse generateAudio(Long vocabularyId) {
        String voiceId = elevenLabsProperties.getVoiceId();
        Optional<AudioCache> existing = audioCacheRepository.findByWordIdAndVoiceId(vocabularyId, voiceId);

        if (existing.isPresent()) {
            return handleExistingCache(existing.get(), vocabularyId, voiceId);
        }

        // No cache row — create a new job
        Word word = wordRepository.findById(vocabularyId)
                .orElseThrow(() -> new ResourceNotFoundException("Word not found: " + vocabularyId));

        try {
            AudioCache saved = audioEnqueueService.createNewJob(word, voiceId);
            nudgeDispatcher();
            return AudioResponse.inProgress(saved.getId(), AudioCacheStatus.PENDING.name());
        } catch (DataIntegrityViolationException e) {
            // Concurrent request already created the row — re-read and reflect actual state
            AudioCache race = audioCacheRepository.findByWordIdAndVoiceId(vocabularyId, voiceId)
                    .orElseThrow(() -> new ResourceNotFoundException("Word not found: " + vocabularyId));
            return buildResponseForCache(race);
        }
    }

    private AudioResponse handleExistingCache(AudioCache cache, Long vocabularyId, String voiceId) {
        return switch (cache.getStatus()) {
            case READY -> buildReadyResponse(cache);

            case PENDING -> {
                Optional<AudioTask> activeTask = audioTaskRepository
                        .findByAudioCacheIdAndStatusIn(cache.getId(), ACTIVE_STATUSES);
                if (activeTask.isPresent()) {
                    yield AudioResponse.inProgress(cache.getId(), AudioCacheStatus.PENDING.name());
                }
                // Orphaned PENDING (no active task) — re-enqueue
                try {
                    audioEnqueueService.enqueueInteractiveTask(cache.getId(), 1);
                    nudgeDispatcher();
                } catch (DataIntegrityViolationException e) {
                    // Concurrent request inserted the task — that's fine, just return PENDING
                }
                yield AudioResponse.inProgress(cache.getId(), AudioCacheStatus.PENDING.name());
            }

            case PROCESSING -> {
                Optional<AudioTask> activeTask = audioTaskRepository
                        .findByAudioCacheIdAndStatusIn(cache.getId(), ACTIVE_STATUSES);

                boolean leaseValid = activeTask
                        .map(t -> t.getLeaseExpiresAt() != null && t.getLeaseExpiresAt().isAfter(Instant.now()))
                        .orElse(false);

                if (leaseValid) {
                    yield AudioResponse.inProgress(cache.getId(), AudioCacheStatus.PROCESSING.name());
                }

                // Stale PROCESSING — check B2 first for self-heal
                String deterministicKey = deterministicKey(vocabularyId, voiceId);
                if (b2StorageClient.objectExists(deterministicKey)) {
                    audioCacheRepository.markReady(cache.getId(), deterministicKey, Instant.now());
                    yield buildReadyResponse(cache.getId(), deterministicKey);
                }

                // Try to abandon the stale task and re-enqueue
                if (activeTask.isPresent()) {
                    AudioTask staleTask = activeTask.get();
                    int abandoned = audioTaskRepository.abandonTask(
                            staleTask.getId(), staleTask.getWorkerToken(), Instant.now());
                    if (abandoned == 0) {
                        // Lost the CAS — re-read current state
                        AudioCache current = audioCacheRepository.findById(cache.getId()).orElseThrow();
                        yield buildResponseForCache(current);
                    }
                }

                try {
                    audioEnqueueService.enqueueInteractiveTask(cache.getId(), 1);
                    nudgeDispatcher();
                } catch (DataIntegrityViolationException e) {
                    // Another request won
                }
                yield AudioResponse.inProgress(cache.getId(), AudioCacheStatus.PENDING.name());
            }

            case FAILED -> {
                String deterministicKey = deterministicKey(vocabularyId, voiceId);
                if (b2StorageClient.objectExists(deterministicKey)) {
                    audioCacheRepository.markReady(cache.getId(), deterministicKey, Instant.now());
                    yield buildReadyResponse(cache.getId(), deterministicKey);
                }
                try {
                    audioEnqueueService.enqueueInteractiveTask(cache.getId(), 1);
                    nudgeDispatcher();
                } catch (DataIntegrityViolationException e) {
                    // Concurrent request already enqueued
                }
                yield AudioResponse.inProgress(cache.getId(), AudioCacheStatus.PENDING.name());
            }
        };
    }

    @Transactional(readOnly = true)
    public AudioResponse getStatus(Long jobId) {
        AudioCache cache = audioCacheRepository.findById(jobId)
                .orElseThrow(() -> new ResourceNotFoundException("Audio job not found: " + jobId));
        return buildResponseForCache(cache);
    }

    private AudioResponse buildResponseForCache(AudioCache cache) {
        return switch (cache.getStatus()) {
            case READY -> buildReadyResponse(cache);
            case FAILED -> AudioResponse.failed(cache.getId(), cache.getLastError());
            case PENDING, PROCESSING -> AudioResponse.inProgress(cache.getId(), cache.getStatus().name());
        };
    }

    private AudioResponse buildReadyResponse(AudioCache cache) {
        String presignedUrl = b2StorageClient.generatePresignedUrl(cache.getB2ObjectKey());
        Instant expiresAt = Instant.now().plusSeconds(b2StorageProperties.getPresignExpirationSeconds());
        return AudioResponse.ready(cache.getId(), presignedUrl, expiresAt);
    }

    private AudioResponse buildReadyResponse(Long cacheId, String objectKey) {
        String presignedUrl = b2StorageClient.generatePresignedUrl(objectKey);
        Instant expiresAt = Instant.now().plusSeconds(b2StorageProperties.getPresignExpirationSeconds());
        return AudioResponse.ready(cacheId, presignedUrl, expiresAt);
    }

    private void nudgeDispatcher() {
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    audioQueueDispatcher.dispatchOnce();
                }
            });
        } else {
            audioQueueDispatcher.dispatchOnce();
        }
    }

    private static String deterministicKey(Long vocabularyId, String voiceId) {
        return "voc/tts/%d/%s.mp3".formatted(vocabularyId, voiceId);
    }
}
