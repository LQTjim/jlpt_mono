package com.jlpt_mono.app.service;

import com.jlpt_mono.app.config.AudioQueueProperties;
import com.jlpt_mono.app.entity.AudioTask;
import com.jlpt_mono.app.entity.AudioTaskStatus;
import com.jlpt_mono.app.repository.AudioCacheRepository;
import com.jlpt_mono.app.repository.AudioTaskRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.annotation.Lazy;
import org.springframework.context.event.EventListener;
import org.springframework.data.domain.PageRequest;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Component
public class AudioRecoveryService {

    private static final Logger log = LoggerFactory.getLogger(AudioRecoveryService.class);

    private final AudioTaskRepository audioTaskRepository;
    private final AudioCacheRepository audioCacheRepository;
    private final AudioEnqueueService audioEnqueueService;
    private final AudioQueueDispatcher audioQueueDispatcher;
    private final AudioQueueProperties props;

    // Self-reference to route recoverOneTask() calls through the Spring proxy
    // so @Transactional is honoured (avoids self-invocation bypass).
    @Autowired @Lazy
    private AudioRecoveryService self;

    public AudioRecoveryService(AudioTaskRepository audioTaskRepository,
            AudioCacheRepository audioCacheRepository,
            AudioEnqueueService audioEnqueueService,
            AudioQueueDispatcher audioQueueDispatcher,
            AudioQueueProperties props) {
        this.audioTaskRepository = audioTaskRepository;
        this.audioCacheRepository = audioCacheRepository;
        this.audioEnqueueService = audioEnqueueService;
        this.audioQueueDispatcher = audioQueueDispatcher;
        this.props = props;
    }

    @EventListener(ApplicationReadyEvent.class)
    public void startupRecovery() {
        log.info("Starting startup recovery scan");
        int total = 0;
        int recovered;
        do {
            recovered = recoverStaleBatch(props.getStartupRecoveryBatch());
            total += recovered;
        } while (recovered > 0);

        if (total > 0) {
            log.info("Startup recovery completed: {} stale tasks recovered", total);
        }
        audioQueueDispatcher.dispatchOnce();
    }

    @Scheduled(fixedDelayString = "${app.audio.queue.recovery-interval}")
    public void scheduledRecovery() {
        recoverStaleBatch(props.getRecoveryBatch());
    }

    int recoverStaleBatch(int limit) {
        Instant now = Instant.now();
        List<AudioTask> stale = audioTaskRepository.findStaleWithCache(
                AudioTaskStatus.CLAIMED, now, PageRequest.of(0, limit));

        int recovered = 0;
        for (AudioTask task : stale) {
            try {
                if (self.recoverOneTask(task, now)) recovered++;
            } catch (Exception e) {
                log.error("Failed to recover stale task: taskId={}", task.getId(), e);
            }
        }
        return recovered;
    }

    /**
     * Atomically abandons a single stale task and enqueues its recovery in one transaction.
     * Each task runs in its own transaction so a failure on one doesn't roll back others.
     */
    @Transactional
    boolean recoverOneTask(AudioTask task, Instant now) {
        int abandoned = audioTaskRepository.abandonTask(task.getId(), task.getWorkerToken(), now);
        if (abandoned == 0) {
            return false; // another recovery instance or the worker itself won the CAS
        }
        Long audioCacheId = task.getAudioCache().getId();
        audioCacheRepository.markPending(audioCacheId, now);
        audioEnqueueService.enqueueRecoveryTask(audioCacheId, task.getAttemptNo(), now);
        log.info("Recovered stale task: taskId={}, audioCacheId={}", task.getId(), audioCacheId);
        return true;
    }
}
