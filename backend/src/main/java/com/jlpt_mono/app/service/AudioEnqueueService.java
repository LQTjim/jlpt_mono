package com.jlpt_mono.app.service;

import com.jlpt_mono.app.entity.*;
import com.jlpt_mono.app.repository.AudioCacheRepository;
import com.jlpt_mono.app.repository.AudioTaskRepository;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

/**
 * Handles AudioCache + AudioTask writes in independent (REQUIRES_NEW) transactions,
 * so that a DataIntegrityViolationException from a concurrent duplicate insert
 * rolls back only the inner transaction, leaving the outer one intact.
 */
@Component
class AudioEnqueueService {

    private final AudioCacheRepository audioCacheRepository;
    private final AudioTaskRepository audioTaskRepository;

    AudioEnqueueService(AudioCacheRepository audioCacheRepository,
                        AudioTaskRepository audioTaskRepository) {
        this.audioCacheRepository = audioCacheRepository;
        this.audioTaskRepository = audioTaskRepository;
    }

    /**
     * Creates a new audio_cache(PENDING) row and its first INTERACTIVE QUEUED task atomically.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    AudioCache createNewJob(Word word, String voiceId) {
        AudioCache cache = new AudioCache();
        cache.setWord(word);
        cache.setVoiceId(voiceId);
        cache.setSourceText(word.getHiragana());
        cache.setStatus(AudioCacheStatus.PENDING);
        AudioCache saved = audioCacheRepository.saveAndFlush(cache);
        insertTask(saved, AudioTaskPriority.INTERACTIVE, AudioTaskOrigin.USER, 1, Instant.now());
        return saved;
    }

    /**
     * Inserts a new INTERACTIVE QUEUED task for an existing audio_cache.
     * Also resets audio_cache to PENDING when it is in FAILED state.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    AudioTask enqueueInteractiveTask(Long audioCacheId, int attemptNo) {
        AudioCache cache = audioCacheRepository.findById(audioCacheId).orElseThrow();
        if (cache.getStatus() != AudioCacheStatus.PENDING) {
            audioCacheRepository.markPending(audioCacheId, Instant.now());
        }
        return insertTask(cache, AudioTaskPriority.INTERACTIVE, AudioTaskOrigin.USER, attemptNo, Instant.now());
    }

    /**
     * Inserts a RECOVERY QUEUED task (used by AudioRecoveryService and retry logic).
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    AudioTask enqueueRecoveryTask(Long audioCacheId, int attemptNo, Instant availableAt) {
        AudioCache cache = audioCacheRepository.findById(audioCacheId).orElseThrow();
        return insertTask(cache, AudioTaskPriority.RECOVERY, AudioTaskOrigin.SCHEDULER, attemptNo, availableAt);
    }

    /**
     * Atomically marks the task SUCCEEDED and the cache READY in a single transaction.
     * Returns the number of rows updated in audio_task (0 = ownership lost, skip cache update).
     * If markReady fails, the transaction rolls back and the task remains CLAIMED for recovery.
     */
    @Transactional
    int completeSuccess(Long taskId, UUID workerToken, Long audioCacheId, String objectKey) {
        Instant now = Instant.now();
        int updated = audioTaskRepository.completeTask(taskId, workerToken, now);
        if (updated > 0) {
            audioCacheRepository.markReady(audioCacheId, objectKey, now);
        }
        return updated;
    }

    private AudioTask insertTask(AudioCache cache, AudioTaskPriority priority,
                                 AudioTaskOrigin origin, int attemptNo, Instant availableAt) {
        AudioTask task = new AudioTask();
        task.setAudioCache(cache);
        task.setStatus(AudioTaskStatus.QUEUED);
        task.setPriority(priority);
        task.setOrigin(origin);
        task.setAttemptNo(attemptNo);
        task.setAvailableAt(availableAt);
        return audioTaskRepository.saveAndFlush(task);
    }
}
