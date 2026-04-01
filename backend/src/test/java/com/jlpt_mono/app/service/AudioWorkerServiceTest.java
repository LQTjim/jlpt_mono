package com.jlpt_mono.app.service;

import com.jlpt_mono.app.config.AudioQueueProperties;
import com.jlpt_mono.app.entity.*;
import com.jlpt_mono.app.exception.TtsException;
import com.jlpt_mono.app.repository.AudioCacheRepository;
import com.jlpt_mono.app.repository.AudioTaskRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AudioWorkerServiceTest {

    @Mock private AudioTaskRepository audioTaskRepository;
    @Mock private AudioCacheRepository audioCacheRepository;
    @Mock private ElevenLabsClient elevenLabsClient;
    @Mock private B2StorageClient b2StorageClient;
    @Mock private AudioEnqueueService audioEnqueueService;
    @Mock private ScheduledExecutorService heartbeatExecutor;
    @Mock private ScheduledFuture<?> heartbeatFuture;

    private AudioWorkerService service;
    private final UUID token = UUID.randomUUID();

    @BeforeEach
    @SuppressWarnings("unchecked")
    void setUp() {
        AudioQueueProperties props = new AudioQueueProperties();
        service = new AudioWorkerService(audioTaskRepository, audioCacheRepository,
                elevenLabsClient, b2StorageClient, audioEnqueueService, props, heartbeatExecutor);

        when(heartbeatExecutor.scheduleAtFixedRate(any(), anyLong(), anyLong(), any()))
                .thenReturn((ScheduledFuture) heartbeatFuture);
    }

    // ── Success path ─────────────────────────────────────────────────────────

    @Test
    @DisplayName("execute — 成功時應呼叫 completeSuccess 並 cancel heartbeat")
    void execute_success_completesAndCancelsHeartbeat() {
        AudioTask task = makeTask(10L, 1L, "こんにちは", 1);
        when(audioTaskRepository.findByIdWithCache(10L)).thenReturn(Optional.of(task));
        when(elevenLabsClient.generateSpeech("こんにちは")).thenReturn(new byte[]{1, 2, 3});
        when(audioEnqueueService.completeSuccess(eq(10L), eq(token), eq(1L), any())).thenReturn(1);

        service.execute(10L, token);

        verify(b2StorageClient).uploadAudio(eq("voc/tts/1/" + token + ".mp3"), any());
        verify(audioEnqueueService).completeSuccess(eq(10L), eq(token), eq(1L), eq("voc/tts/1/" + token + ".mp3"));
        verify(heartbeatFuture).cancel(false);
    }

    @Test
    @DisplayName("execute — completeSuccess 回傳 0（ownership 丟失）時應靜默返回，不呼叫 handleFailure")
    void execute_ownershipLostAtComplete_returnsQuietly() {
        AudioTask task = makeTask(10L, 1L, "こんにちは", 1);
        when(audioTaskRepository.findByIdWithCache(10L)).thenReturn(Optional.of(task));
        when(elevenLabsClient.generateSpeech(any())).thenReturn(new byte[]{1});
        when(audioEnqueueService.completeSuccess(any(), any(), any(), any())).thenReturn(0);

        service.execute(10L, token);

        verify(audioEnqueueService, never()).enqueueRecoveryTask(any(), anyInt(), any());
        verifyNoInteractions(audioCacheRepository);
        verify(heartbeatFuture).cancel(false);
    }

    @Test
    @DisplayName("execute — completeSuccess 拋出例外時應走 handleFailure retryable 路徑")
    void execute_completeSuccessThrows_treatedAsRetryableFailure() {
        AudioTask task = makeTask(10L, 1L, "こんにちは", 1);
        when(audioTaskRepository.findByIdWithCache(10L)).thenReturn(Optional.of(task));
        when(elevenLabsClient.generateSpeech(any())).thenReturn(new byte[]{1});
        when(audioEnqueueService.completeSuccess(any(), any(), any(), any()))
                .thenThrow(new RuntimeException("DB connection lost"));
        when(audioTaskRepository.markTaskFinishedIfOwned(any(), any(), any(), any(), any())).thenReturn(1);

        service.execute(10L, token);

        verify(audioTaskRepository).markTaskFinishedIfOwned(
                eq(10L), eq(token), eq(AudioTaskStatus.RETRYABLE_FAILED), any(), any());
        verify(audioCacheRepository).markPending(eq(1L), any());
        verify(heartbeatFuture).cancel(false);
    }

    // ── Retryable failure path ────────────────────────────────────────────────

    @Test
    @DisplayName("execute — retryable TtsException 且有剩餘次數時應排程 retry task")
    void execute_retryableTtsException_enqueuesRetryTask() {
        AudioTask task = makeTask(10L, 1L, "こんにちは", 1);
        when(audioTaskRepository.findByIdWithCache(10L)).thenReturn(Optional.of(task));
        when(elevenLabsClient.generateSpeech(any()))
                .thenThrow(new TtsException("429 rate limit", null, true));
        when(audioTaskRepository.markTaskFinishedIfOwned(any(), any(), any(), any(), any())).thenReturn(1);

        service.execute(10L, token);

        verify(audioTaskRepository).markTaskFinishedIfOwned(
                eq(10L), eq(token), eq(AudioTaskStatus.RETRYABLE_FAILED), any(), any());
        verify(audioEnqueueService).enqueueRecoveryTask(eq(1L), eq(2), any(Instant.class));
        verify(audioCacheRepository).markPending(eq(1L), any());
    }

    @Test
    @DisplayName("execute — retry 排程中 ownership 已丟失時應靜默返回")
    void execute_retryableTtsException_ownershipLostBeforeRetry_returnsQuietly() {
        AudioTask task = makeTask(10L, 1L, "こんにちは", 1);
        when(audioTaskRepository.findByIdWithCache(10L)).thenReturn(Optional.of(task));
        when(elevenLabsClient.generateSpeech(any()))
                .thenThrow(new TtsException("429", null, true));
        when(audioTaskRepository.markTaskFinishedIfOwned(any(), any(), any(), any(), any())).thenReturn(0);

        service.execute(10L, token);

        verify(audioEnqueueService, never()).enqueueRecoveryTask(any(), anyInt(), any());
        verifyNoInteractions(audioCacheRepository);
    }

    @Test
    @DisplayName("execute — backoff 應隨 attemptNo 遞增（attempt 2 → 120s）")
    void execute_backoffIncreasesWithAttemptNo() {
        AudioTask task = makeTask(10L, 1L, "こんにちは", 2); // attempt 2
        when(audioTaskRepository.findByIdWithCache(10L)).thenReturn(Optional.of(task));
        when(elevenLabsClient.generateSpeech(any()))
                .thenThrow(new TtsException("500", null, true));
        when(audioTaskRepository.markTaskFinishedIfOwned(any(), any(), any(), any(), any())).thenReturn(1);

        Instant before = Instant.now();
        service.execute(10L, token);

        verify(audioEnqueueService).enqueueRecoveryTask(eq(1L), eq(3),
                argThat(availableAt -> availableAt.isAfter(before.plusSeconds(115))));
    }

    // ── Dead-letter path ──────────────────────────────────────────────────────

    @Test
    @DisplayName("execute — non-retryable TtsException 應直接 dead-letter")
    void execute_nonRetryableTtsException_deadLetters() {
        AudioTask task = makeTask(10L, 1L, "こんにちは", 1);
        when(audioTaskRepository.findByIdWithCache(10L)).thenReturn(Optional.of(task));
        when(elevenLabsClient.generateSpeech(any()))
                .thenThrow(new TtsException("401 unauthorized", null, false));
        when(audioTaskRepository.markTaskFinishedIfOwned(any(), any(), any(), any(), any())).thenReturn(1);
        when(audioCacheRepository.markFailedIfProcessing(any(), any(), any())).thenReturn(1);

        service.execute(10L, token);

        verify(audioTaskRepository).markTaskFinishedIfOwned(
                eq(10L), eq(token), eq(AudioTaskStatus.DEAD_LETTER), any(), any());
        verify(audioCacheRepository).markFailedIfProcessing(eq(1L), any(), any());
        verify(audioEnqueueService, never()).enqueueRecoveryTask(any(), anyInt(), any());
    }

    @Test
    @DisplayName("execute — maxAttempts 耗盡時應 dead-letter 而非 retry")
    void execute_maxAttemptsExhausted_deadLetters() {
        AudioQueueProperties props = new AudioQueueProperties(); // maxAttempts = 5
        service = new AudioWorkerService(audioTaskRepository, audioCacheRepository,
                elevenLabsClient, b2StorageClient, audioEnqueueService, props, heartbeatExecutor);

        AudioTask task = makeTask(10L, 1L, "こんにちは", 5); // last attempt
        when(audioTaskRepository.findByIdWithCache(10L)).thenReturn(Optional.of(task));
        when(elevenLabsClient.generateSpeech(any()))
                .thenThrow(new TtsException("500", null, true));
        when(audioTaskRepository.markTaskFinishedIfOwned(any(), any(), any(), any(), any())).thenReturn(1);
        when(audioCacheRepository.markFailedIfProcessing(any(), any(), any())).thenReturn(1);

        service.execute(10L, token);

        verify(audioTaskRepository).markTaskFinishedIfOwned(
                eq(10L), eq(token), eq(AudioTaskStatus.DEAD_LETTER), any(), any());
        verify(audioEnqueueService, never()).enqueueRecoveryTask(any(), anyInt(), any());
    }

    @Test
    @DisplayName("execute — dead-letter 時 cache 已被並發重新排程（markFailedIfProcessing 回 0）應跳過覆寫")
    void execute_deadLetter_cacheAlreadyRequeued_skipsMarkFailed() {
        AudioTask task = makeTask(10L, 1L, "こんにちは", 1);
        when(audioTaskRepository.findByIdWithCache(10L)).thenReturn(Optional.of(task));
        when(elevenLabsClient.generateSpeech(any()))
                .thenThrow(new TtsException("401", null, false));
        when(audioTaskRepository.markTaskFinishedIfOwned(any(), any(), any(), any(), any())).thenReturn(1);
        when(audioCacheRepository.markFailedIfProcessing(any(), any(), any())).thenReturn(0); // already re-queued

        service.execute(10L, token);

        verify(audioCacheRepository).markFailedIfProcessing(eq(1L), any(), any());
        // markFailed (unconditional) must NOT be called
        verify(audioCacheRepository, never()).markFailed(any(), any(), any());
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private AudioTask makeTask(Long taskId, Long wordId, String sourceText, int attemptNo) {
        Word word = new Word();
        word.setId(wordId);

        AudioCache cache = new AudioCache();
        cache.setId(1L);
        cache.setWord(word);
        cache.setVoiceId(token.toString());
        cache.setSourceText(sourceText);
        cache.setStatus(AudioCacheStatus.PROCESSING);

        AudioTask task = new AudioTask();
        task.setId(taskId);
        task.setAudioCache(cache);
        task.setStatus(AudioTaskStatus.CLAIMED);
        task.setPriority(AudioTaskPriority.INTERACTIVE);
        task.setOrigin(AudioTaskOrigin.USER);
        task.setAttemptNo(attemptNo);
        task.setWorkerToken(token);
        return task;
    }
}
