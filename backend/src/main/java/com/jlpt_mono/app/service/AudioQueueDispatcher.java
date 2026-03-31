package com.jlpt_mono.app.service;

import com.jlpt_mono.app.config.AudioQueueProperties;
import com.jlpt_mono.app.entity.AudioTask;
import com.jlpt_mono.app.repository.AudioCacheRepository;
import com.jlpt_mono.app.repository.AudioTaskRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.Executor;

@Component
public class AudioQueueDispatcher {

    private static final Logger log = LoggerFactory.getLogger(AudioQueueDispatcher.class);

    private final AudioTaskRepository audioTaskRepository;
    private final AudioCacheRepository audioCacheRepository;
    private final AudioWorkerService audioWorkerService;
    private final AudioQueueProperties props;
    private final Executor workerExecutor;

    public AudioQueueDispatcher(AudioTaskRepository audioTaskRepository,
                                AudioCacheRepository audioCacheRepository,
                                AudioWorkerService audioWorkerService,
                                AudioQueueProperties props,
                                @Qualifier("workerExecutor") Executor workerExecutor) {
        this.audioTaskRepository = audioTaskRepository;
        this.audioCacheRepository = audioCacheRepository;
        this.audioWorkerService = audioWorkerService;
        this.props = props;
        this.workerExecutor = workerExecutor;
    }

    @Scheduled(fixedDelayString = "${app.audio.queue.dispatch-interval}")
    public void scheduledDispatch() {
        dispatchOnce();
    }

    /**
     * Claims available QUEUED tasks and submits them to the worker executor.
     * Called by the scheduler and by the after-commit nudge in AudioService.
     */
    @Transactional
    public void dispatchOnce() {
        UUID token = UUID.randomUUID();
        List<Long> ids = audioTaskRepository.claimBatch(
                props.getDispatchBatch(),
                props.getLeaseDuration().toSeconds(),
                token.toString());

        if (ids.isEmpty()) return;

        log.debug("Dispatcher claimed {} tasks", ids.size());

        List<Long> scheduledIds = new ArrayList<>();
        for (Long taskId : ids) {
            AudioTask task = audioTaskRepository.findById(taskId).orElse(null);
            if (task == null) continue;
            audioCacheRepository.markProcessing(task.getAudioCache().getId(), Instant.now());
            scheduledIds.add(taskId);
        }

        // Submit workers only after the claim transaction commits to avoid race between
        // worker completion and an uncommitted claim.
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    scheduledIds.forEach(taskId ->
                            workerExecutor.execute(() -> audioWorkerService.execute(taskId, token)));
                }
            });
        } else {
            scheduledIds.forEach(taskId ->
                    workerExecutor.execute(() -> audioWorkerService.execute(taskId, token)));
        }
    }
}
