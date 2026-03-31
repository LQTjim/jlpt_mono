package com.jlpt_mono.app.service;

import com.jlpt_mono.app.config.AudioQueueProperties;
import com.jlpt_mono.app.config.B2StorageProperties;
import com.jlpt_mono.app.config.ElevenLabsProperties;
import com.jlpt_mono.app.dto.AudioResponse;
import com.jlpt_mono.app.entity.*;
import com.jlpt_mono.app.exception.ResourceNotFoundException;
import com.jlpt_mono.app.repository.AudioCacheRepository;
import com.jlpt_mono.app.repository.AudioTaskRepository;
import com.jlpt_mono.app.repository.WordRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AudioServiceTest {

    @Mock private AudioCacheRepository audioCacheRepository;
    @Mock private AudioTaskRepository audioTaskRepository;
    @Mock private WordRepository wordRepository;
    @Mock private AudioEnqueueService audioEnqueueService;
    @Mock private AudioQueueDispatcher audioQueueDispatcher;
    @Mock private B2StorageClient b2StorageClient;

    private AudioService service;

    private final String voiceId = "test-voice-id";

    @BeforeEach
    void setUp() {
        ElevenLabsProperties elevenLabsProps = new ElevenLabsProperties();
        elevenLabsProps.setVoiceId(voiceId);

        B2StorageProperties b2Props = new B2StorageProperties();
        b2Props.setPresignExpirationSeconds(900);

        service = new AudioService(audioCacheRepository, audioTaskRepository, wordRepository,
                audioEnqueueService, audioQueueDispatcher, b2StorageClient,
                elevenLabsProps, b2Props, new AudioQueueProperties());
    }

    @Test
    @DisplayName("generateAudio — cache READY 時應回傳 presignedUrl")
    void generateAudio_cacheReady_returnPresignedUrl() {
        AudioCache cache = cacheWithStatus(10L, AudioCacheStatus.READY);
        cache.setB2ObjectKey("voc/tts/1/voice.mp3");
        when(audioCacheRepository.findByWordIdAndVoiceId(1L, voiceId)).thenReturn(Optional.of(cache));
        when(b2StorageClient.generatePresignedUrl("voc/tts/1/voice.mp3")).thenReturn("https://presigned.url");

        AudioResponse result = service.generateAudio(1L);

        assertThat(result.status()).isEqualTo("READY");
        assertThat(result.presignedUrl()).isEqualTo("https://presigned.url");
        assertThat(result.expiresAt()).isAfter(Instant.now());
    }

    @Test
    @DisplayName("generateAudio — cache PENDING 且有 active task 時應回傳 202")
    void generateAudio_cachePending_activeTask_returnsPending() {
        AudioCache cache = cacheWithStatus(10L, AudioCacheStatus.PENDING);
        when(audioCacheRepository.findByWordIdAndVoiceId(1L, voiceId)).thenReturn(Optional.of(cache));
        when(audioTaskRepository.findByAudioCacheIdAndStatusIn(eq(10L), any()))
                .thenReturn(Optional.of(queuedTask(10L)));

        AudioResponse result = service.generateAudio(1L);

        assertThat(result.status()).isEqualTo("PENDING");
        assertThat(result.presignedUrl()).isNull();
        verifyNoInteractions(audioEnqueueService);
    }

    @Test
    @DisplayName("generateAudio — cache PENDING 但無 active task（孤兒）時應重新排程")
    void generateAudio_cachePending_orphaned_requeues() {
        AudioCache cache = cacheWithStatus(10L, AudioCacheStatus.PENDING);
        when(audioCacheRepository.findByWordIdAndVoiceId(1L, voiceId)).thenReturn(Optional.of(cache));
        when(audioTaskRepository.findByAudioCacheIdAndStatusIn(eq(10L), any()))
                .thenReturn(Optional.empty());
        when(audioEnqueueService.enqueueInteractiveTask(10L, 1)).thenReturn(queuedTask(10L));

        AudioResponse result = service.generateAudio(1L);

        assertThat(result.status()).isEqualTo("PENDING");
        verify(audioEnqueueService).enqueueInteractiveTask(10L, 1);
    }

    @Test
    @DisplayName("generateAudio — cache PROCESSING lease 未過期時應回傳 202")
    void generateAudio_cacheProcessing_leaseValid_returnsProcessing() {
        AudioCache cache = cacheWithStatus(10L, AudioCacheStatus.PROCESSING);
        when(audioCacheRepository.findByWordIdAndVoiceId(1L, voiceId)).thenReturn(Optional.of(cache));

        AudioTask claimedTask = queuedTask(10L);
        claimedTask.setStatus(AudioTaskStatus.CLAIMED);
        claimedTask.setLeaseExpiresAt(Instant.now().plusSeconds(60));
        claimedTask.setWorkerToken(java.util.UUID.randomUUID());
        when(audioTaskRepository.findByAudioCacheIdAndStatusIn(eq(10L), any()))
                .thenReturn(Optional.of(claimedTask));

        AudioResponse result = service.generateAudio(1L);

        assertThat(result.status()).isEqualTo("PROCESSING");
        verifyNoInteractions(audioEnqueueService);
    }

    @Test
    @DisplayName("generateAudio — stale PROCESSING + B2 物件存在時應自愈為 READY")
    void generateAudio_staleProcessing_b2Exists_selfHealsToReady() {
        AudioCache cache = cacheWithStatus(10L, AudioCacheStatus.PROCESSING);
        when(audioCacheRepository.findByWordIdAndVoiceId(1L, voiceId)).thenReturn(Optional.of(cache));

        AudioTask staleTask = queuedTask(10L);
        staleTask.setStatus(AudioTaskStatus.CLAIMED);
        staleTask.setLeaseExpiresAt(Instant.now().minusSeconds(60)); // expired
        staleTask.setWorkerToken(java.util.UUID.randomUUID());
        when(audioTaskRepository.findByAudioCacheIdAndStatusIn(eq(10L), any()))
                .thenReturn(Optional.of(staleTask));

        String key = "voc/tts/1/" + voiceId + ".mp3";
        when(b2StorageClient.objectExists(key)).thenReturn(true);
        when(b2StorageClient.generatePresignedUrl(key)).thenReturn("https://presigned.url");

        AudioResponse result = service.generateAudio(1L);

        assertThat(result.status()).isEqualTo("READY");
        verify(audioCacheRepository).markReady(eq(10L), eq(key), any());
    }

    @Test
    @DisplayName("generateAudio — stale PROCESSING + B2 無物件 + CAS abandon 成功時應重新排程")
    void generateAudio_staleProcessing_b2Missing_abandonWon_requeues() {
        AudioCache cache = cacheWithStatus(10L, AudioCacheStatus.PROCESSING);
        when(audioCacheRepository.findByWordIdAndVoiceId(1L, voiceId)).thenReturn(Optional.of(cache));

        java.util.UUID token = java.util.UUID.randomUUID();
        AudioTask staleTask = queuedTask(10L);
        staleTask.setStatus(AudioTaskStatus.CLAIMED);
        staleTask.setLeaseExpiresAt(Instant.now().minusSeconds(60));
        staleTask.setWorkerToken(token);
        when(audioTaskRepository.findByAudioCacheIdAndStatusIn(eq(10L), any()))
                .thenReturn(Optional.of(staleTask));

        when(b2StorageClient.objectExists(any())).thenReturn(false);
        when(audioTaskRepository.abandonTask(eq(staleTask.getId()), eq(token), any())).thenReturn(1);
        when(audioEnqueueService.enqueueInteractiveTask(10L, 1)).thenReturn(queuedTask(10L));

        AudioResponse result = service.generateAudio(1L);

        assertThat(result.status()).isEqualTo("PENDING");
        verify(audioEnqueueService).enqueueInteractiveTask(10L, 1);
    }

    @Test
    @DisplayName("generateAudio — stale PROCESSING + CAS abandon 失敗時應回傳重讀的現況")
    void generateAudio_staleProcessing_abandonLost_readsCurrentState() {
        AudioCache cache = cacheWithStatus(10L, AudioCacheStatus.PROCESSING);
        when(audioCacheRepository.findByWordIdAndVoiceId(1L, voiceId)).thenReturn(Optional.of(cache));

        java.util.UUID token = java.util.UUID.randomUUID();
        AudioTask staleTask = queuedTask(10L);
        staleTask.setStatus(AudioTaskStatus.CLAIMED);
        staleTask.setLeaseExpiresAt(Instant.now().minusSeconds(60));
        staleTask.setWorkerToken(token);
        when(audioTaskRepository.findByAudioCacheIdAndStatusIn(eq(10L), any()))
                .thenReturn(Optional.of(staleTask));

        when(b2StorageClient.objectExists(any())).thenReturn(false);
        when(audioTaskRepository.abandonTask(eq(staleTask.getId()), eq(token), any())).thenReturn(0);

        AudioCache reread = cacheWithStatus(10L, AudioCacheStatus.PENDING);
        when(audioCacheRepository.findById(10L)).thenReturn(Optional.of(reread));

        AudioResponse result = service.generateAudio(1L);

        assertThat(result.status()).isEqualTo("PENDING");
        verifyNoInteractions(audioEnqueueService);
    }

    @Test
    @DisplayName("generateAudio — cache FAILED + B2 物件存在時應自愈為 READY")
    void generateAudio_failed_b2Exists_selfHealsToReady() {
        AudioCache cache = cacheWithStatus(10L, AudioCacheStatus.FAILED);
        when(audioCacheRepository.findByWordIdAndVoiceId(1L, voiceId)).thenReturn(Optional.of(cache));

        String key = "voc/tts/1/" + voiceId + ".mp3";
        when(b2StorageClient.objectExists(key)).thenReturn(true);
        when(b2StorageClient.generatePresignedUrl(key)).thenReturn("https://presigned.url");

        AudioResponse result = service.generateAudio(1L);

        assertThat(result.status()).isEqualTo("READY");
        verify(audioCacheRepository).markReady(eq(10L), eq(key), any());
        verifyNoInteractions(audioEnqueueService);
    }

    @Test
    @DisplayName("generateAudio — cache FAILED + B2 無物件時應重新排程")
    void generateAudio_failed_b2Missing_requeues() {
        AudioCache cache = cacheWithStatus(10L, AudioCacheStatus.FAILED);
        when(audioCacheRepository.findByWordIdAndVoiceId(1L, voiceId)).thenReturn(Optional.of(cache));
        when(b2StorageClient.objectExists(any())).thenReturn(false);
        when(audioEnqueueService.enqueueInteractiveTask(10L, 1)).thenReturn(queuedTask(10L));

        AudioResponse result = service.generateAudio(1L);

        assertThat(result.status()).isEqualTo("PENDING");
        verify(audioEnqueueService).enqueueInteractiveTask(10L, 1);
    }

    @Test
    @DisplayName("generateAudio — cache 不存在時應建立新 job 並排程")
    void generateAudio_noCache_createsAndQueues() {
        when(audioCacheRepository.findByWordIdAndVoiceId(1L, voiceId)).thenReturn(Optional.empty());
        Word word = new Word();
        word.setId(1L);
        word.setHiragana("こんにちは");
        when(wordRepository.findById(1L)).thenReturn(Optional.of(word));

        AudioCache saved = cacheWithStatus(10L, AudioCacheStatus.PENDING);
        when(audioEnqueueService.createNewJob(word, voiceId)).thenReturn(saved);

        AudioResponse result = service.generateAudio(1L);

        assertThat(result.status()).isEqualTo("PENDING");
        verify(audioEnqueueService).createNewJob(word, voiceId);
    }

    @Test
    @DisplayName("generateAudio — 並發 insert 衝突時應重讀現有 row")
    void generateAudio_concurrentInsert_readsExistingRow() {
        when(audioCacheRepository.findByWordIdAndVoiceId(1L, voiceId)).thenReturn(Optional.empty());
        Word word = new Word();
        word.setId(1L);
        word.setHiragana("こんにちは");
        when(wordRepository.findById(1L)).thenReturn(Optional.of(word));
        when(audioEnqueueService.createNewJob(word, voiceId))
                .thenThrow(new org.springframework.dao.DataIntegrityViolationException("unique"));

        AudioCache raceRow = cacheWithStatus(10L, AudioCacheStatus.PENDING);
        when(audioCacheRepository.findByWordIdAndVoiceId(1L, voiceId))
                .thenReturn(Optional.empty())
                .thenReturn(Optional.of(raceRow));

        AudioResponse result = service.generateAudio(1L);

        assertThat(result.status()).isEqualTo("PENDING");
    }

    @Test
    @DisplayName("generateAudio — vocabularyId 不存在時應拋出 ResourceNotFoundException")
    void generateAudio_wordNotFound_throwsNotFound() {
        when(audioCacheRepository.findByWordIdAndVoiceId(99L, voiceId)).thenReturn(Optional.empty());
        when(wordRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.generateAudio(99L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("getStatus — READY 時應回傳 presignedUrl")
    void getStatus_ready_returnsPresignedUrl() {
        AudioCache cache = cacheWithStatus(10L, AudioCacheStatus.READY);
        cache.setB2ObjectKey("voc/tts/1/voice.mp3");
        when(audioCacheRepository.findById(10L)).thenReturn(Optional.of(cache));
        when(b2StorageClient.generatePresignedUrl("voc/tts/1/voice.mp3")).thenReturn("https://presigned.url");

        AudioResponse result = service.getStatus(10L);

        assertThat(result.status()).isEqualTo("READY");
        assertThat(result.presignedUrl()).isEqualTo("https://presigned.url");
    }

    @Test
    @DisplayName("getStatus — FAILED 時應回傳 errorMessage")
    void getStatus_failed_returnsErrorMessage() {
        AudioCache cache = cacheWithStatus(10L, AudioCacheStatus.FAILED);
        cache.setLastError("TTS API error: 401");
        when(audioCacheRepository.findById(10L)).thenReturn(Optional.of(cache));

        AudioResponse result = service.getStatus(10L);

        assertThat(result.status()).isEqualTo("FAILED");
        assertThat(result.errorMessage()).isEqualTo("TTS API error: 401");
    }

    @Test
    @DisplayName("getStatus — job 不存在時應拋出 ResourceNotFoundException")
    void getStatus_notFound_throwsException() {
        when(audioCacheRepository.findById(999L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.getStatus(999L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    private AudioCache cacheWithStatus(Long id, AudioCacheStatus status) {
        Word word = new Word();
        word.setId(1L);

        AudioCache cache = new AudioCache();
        cache.setId(id);
        cache.setWord(word);
        cache.setVoiceId(voiceId);
        cache.setSourceText("こんにちは");
        cache.setStatus(status);
        return cache;
    }

    private AudioTask queuedTask(Long audioCacheId) {
        AudioCache cache = new AudioCache();
        cache.setId(audioCacheId);
        AudioTask task = new AudioTask();
        task.setId(audioCacheId * 100);
        task.setAudioCache(cache);
        task.setStatus(AudioTaskStatus.QUEUED);
        task.setPriority(AudioTaskPriority.INTERACTIVE);
        task.setOrigin(AudioTaskOrigin.USER);
        task.setAttemptNo(1);
        return task;
    }
}
