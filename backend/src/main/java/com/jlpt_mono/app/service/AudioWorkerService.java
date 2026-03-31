package com.jlpt_mono.app.service;

import com.jlpt_mono.app.config.AudioQueueProperties;
import com.jlpt_mono.app.entity.AudioTask;
import com.jlpt_mono.app.entity.AudioTaskStatus;
import com.jlpt_mono.app.exception.TtsException;
import com.jlpt_mono.app.repository.AudioCacheRepository;
import com.jlpt_mono.app.repository.AudioTaskRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.UUID;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

@Service
public class AudioWorkerService {

    private static final Logger log = LoggerFactory.getLogger(AudioWorkerService.class);

    static final long[] BACKOFF_SECONDS = {30, 120, 300, 900, 1800};

    private final AudioTaskRepository audioTaskRepository;
    private final AudioCacheRepository audioCacheRepository;
    private final ElevenLabsClient elevenLabsClient;
    private final B2StorageClient b2StorageClient;
    private final AudioEnqueueService audioEnqueueService;
    private final AudioQueueProperties props;
    private final ScheduledExecutorService heartbeatExecutor;

    public AudioWorkerService(AudioTaskRepository audioTaskRepository,
                              AudioCacheRepository audioCacheRepository,
                              ElevenLabsClient elevenLabsClient,
                              B2StorageClient b2StorageClient,
                              AudioEnqueueService audioEnqueueService,
                              AudioQueueProperties props,
                              @Qualifier("heartbeatExecutor") ScheduledExecutorService heartbeatExecutor) {
        this.audioTaskRepository = audioTaskRepository;
        this.audioCacheRepository = audioCacheRepository;
        this.elevenLabsClient = elevenLabsClient;
        this.b2StorageClient = b2StorageClient;
        this.audioEnqueueService = audioEnqueueService;
        this.props = props;
        this.heartbeatExecutor = heartbeatExecutor;
    }

    public void execute(Long taskId, UUID workerToken) {
        AudioTask task = audioTaskRepository.findById(taskId)
                .orElseThrow(() -> new IllegalStateException("AudioTask not found: " + taskId));

        Long audioCacheId = task.getAudioCache().getId();
        Long wordId = task.getAudioCache().getWord().getId();
        String voiceId = task.getAudioCache().getVoiceId();
        String sourceText = task.getAudioCache().getSourceText();
        int attemptNo = task.getAttemptNo();

        AtomicBoolean ownershipLost = new AtomicBoolean(false);
        ScheduledFuture<?> heartbeat = startHeartbeat(taskId, workerToken, ownershipLost);

        try {
            byte[] audioBytes = elevenLabsClient.generateSpeech(sourceText);

            String objectKey = "voc/tts/%d/%s.mp3".formatted(wordId, voiceId);
            b2StorageClient.uploadAudio(objectKey, audioBytes);

            int updated = audioEnqueueService.completeSuccess(taskId, workerToken, audioCacheId, objectKey);
            if (updated == 0) {
                log.warn("Worker lost ownership before completion: taskId={}", taskId);
                return;
            }
            log.info("Audio task completed: taskId={}, key={}", taskId, objectKey);

        } catch (TtsException e) {
            if (ownershipLost.get()) {
                log.warn("TtsException after ownership lost, discarding: taskId={}", taskId);
                return;
            }
            handleFailure(task, audioCacheId, attemptNo, workerToken, e, e.isRetryable());

        } catch (Exception e) {
            if (ownershipLost.get()) {
                log.warn("Exception after ownership lost, discarding: taskId={}", taskId);
                return;
            }
            handleFailure(task, audioCacheId, attemptNo, workerToken, e, true);

        } finally {
            heartbeat.cancel(false);
        }
    }

    private void handleFailure(AudioTask task, Long audioCacheId, int attemptNo,
                                UUID workerToken, Exception e, boolean retryable) {
        String errorMsg = truncate(e.getMessage(), 1000);
        Instant now = Instant.now();

        if (retryable && attemptNo < props.getMaxAttempts()) {
            long backoffSecs = BACKOFF_SECONDS[Math.min(attemptNo - 1, BACKOFF_SECONDS.length - 1)];
            Instant availableAt = now.plusSeconds(backoffSecs);

            // Fence: transition task out of CLAIMED first so the partial unique index allows the retry insert
            int owned = audioTaskRepository.markTaskFinishedIfOwned(
                    task.getId(), workerToken, AudioTaskStatus.RETRYABLE_FAILED, errorMsg, now);
            if (owned == 0) {
                log.warn("handleFailure: ownership lost before retry enqueue, discarding: taskId={}", task.getId());
                return;
            }
            try {
                audioEnqueueService.enqueueRecoveryTask(audioCacheId, attemptNo + 1, availableAt);
            } catch (Exception enqueueEx) {
                log.error("Failed to enqueue retry task for audioCacheId={}: {}", audioCacheId, enqueueEx.getMessage());
            }
            audioCacheRepository.markPending(audioCacheId, now);
            log.warn("Audio task failed (retryable), attempt={}/{}: taskId={}, error={}",
                    attemptNo, props.getMaxAttempts(), task.getId(), errorMsg);
        } else {
            int owned = audioTaskRepository.markTaskFinishedIfOwned(
                    task.getId(), workerToken, AudioTaskStatus.DEAD_LETTER, errorMsg, now);
            if (owned == 0) {
                log.warn("handleFailure: ownership lost before dead-letter, discarding: taskId={}", task.getId());
                return;
            }
            int cacheUpdated = audioCacheRepository.markFailedIfProcessing(audioCacheId, errorMsg, now);
            if (cacheUpdated == 0) {
                log.warn("Dead-letter: cache already re-queued by concurrent request, skipping markFailed: audioCacheId={}", audioCacheId);
            }
            log.error("Audio task dead-lettered: taskId={}, error={}", task.getId(), errorMsg);
        }
    }

    private ScheduledFuture<?> startHeartbeat(Long taskId, UUID workerToken, AtomicBoolean ownershipLost) {
        long intervalMs = props.getHeartbeatInterval().toMillis();
        return heartbeatExecutor.scheduleAtFixedRate(() -> {
            try {
                Instant newLease = Instant.now().plus(props.getLeaseDuration());
                int updated = audioTaskRepository.renewLease(taskId, workerToken, newLease, Instant.now());
                if (updated == 0) {
                    ownershipLost.set(true);
                    log.warn("Heartbeat lost ownership: taskId={}", taskId);
                    throw new RuntimeException("ownership lost — stop heartbeat");
                }
            } catch (RuntimeException e) {
                throw e;
            } catch (Exception e) {
                log.error("Heartbeat renew error: taskId={}", taskId, e);
            }
        }, intervalMs, intervalMs, TimeUnit.MILLISECONDS);
    }

    private String truncate(String value, int maxLength) {
        if (value == null) return null;
        return value.length() <= maxLength ? value : value.substring(0, maxLength);
    }
}
