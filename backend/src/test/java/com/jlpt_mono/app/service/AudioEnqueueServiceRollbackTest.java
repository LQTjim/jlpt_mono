package com.jlpt_mono.app.service;

import com.jlpt_mono.app.entity.*;
import com.jlpt_mono.app.repository.AudioCacheRepository;
import com.jlpt_mono.app.repository.AudioTaskRepository;
import com.jlpt_mono.app.repository.WordRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.testcontainers.containers.PostgreSQLContainer;

import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;

/**
 * DB-level rollback guarantee for {@link AudioEnqueueService#completeSuccess}.
 *
 * <p>Uses a real PostgreSQL container (via Testcontainers) with Liquibase migrations applied,
 * so the assertions read from the actual database — not a mock.
 *
 * <p>NO class-level {@code @Transactional}: each test method must let
 * {@code completeSuccess()} own and commit/rollback its own transaction.
 */
@SpringBootTest
@Import(AudioEnqueueServiceRollbackTest.ContainersConfig.class)
@ActiveProfiles("test")
class AudioEnqueueServiceRollbackTest {

    @TestConfiguration(proxyBeanMethods = false)
    static class ContainersConfig {
        @Bean
        @ServiceConnection
        PostgreSQLContainer<?> postgresContainer() {
            return new PostgreSQLContainer<>("postgres:17");
        }
    }

    @Autowired private AudioEnqueueService audioEnqueueService;
    @Autowired private AudioTaskRepository audioTaskRepository;
    @Autowired private WordRepository wordRepository;

    @MockitoSpyBean private AudioCacheRepository audioCacheRepository;

    private Word word;
    private AudioCache cache;
    private AudioTask task;
    private final UUID token = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        word = new Word();
        word.setHiragana("こんにちは");
        word = wordRepository.save(word);

        cache = new AudioCache();
        cache.setWord(word);
        cache.setVoiceId(token.toString());
        cache.setSourceText("こんにちは");
        cache.setStatus(AudioCacheStatus.PROCESSING);
        cache = audioCacheRepository.save(cache);

        task = new AudioTask();
        task.setAudioCache(cache);
        task.setStatus(AudioTaskStatus.CLAIMED);
        task.setPriority(AudioTaskPriority.INTERACTIVE);
        task.setOrigin(AudioTaskOrigin.USER);
        task.setAttemptNo(1);
        task.setWorkerToken(token);
        task.setAvailableAt(Instant.now());
        task.setClaimedAt(Instant.now());
        task.setLeaseExpiresAt(Instant.now().plusSeconds(120));
        task = audioTaskRepository.save(task);
    }

    @AfterEach
    void tearDown() {
        audioTaskRepository.deleteById(task.getId());
        audioCacheRepository.deleteById(cache.getId());
        wordRepository.deleteById(word.getId());
    }

    @Test
    @DisplayName("completeSuccess — markReady 拋出例外時，整個事務回滾：task 維持 CLAIMED，cache 維持 PROCESSING")
    void completeSuccess_markReadyThrows_rollbackKeepsBothInOriginalState() {
        doThrow(new RuntimeException("simulated DB failure"))
                .when(audioCacheRepository).markReady(any(), any(), any());

        assertThatThrownBy(() ->
                audioEnqueueService.completeSuccess(task.getId(), token, cache.getId(), "voc/tts/1/voice.mp3"))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("simulated DB failure");

        // Read from DB — not from JPA first-level cache
        AudioTask reloadedTask = audioTaskRepository.findById(task.getId()).orElseThrow();
        AudioCache reloadedCache = audioCacheRepository.findById(cache.getId()).orElseThrow();

        assertThat(reloadedTask.getStatus())
                .as("task must stay CLAIMED so the recovery service can pick it up")
                .isEqualTo(AudioTaskStatus.CLAIMED);
        assertThat(reloadedCache.getStatus())
                .as("cache must stay PROCESSING — SUCCEEDED+PROCESSING is the stuck state we're preventing")
                .isEqualTo(AudioCacheStatus.PROCESSING);
    }

    @Test
    @DisplayName("completeSuccess — 成功時 task → SUCCEEDED，cache → READY，b2ObjectKey 寫入")
    void completeSuccess_success_persistsBothStateChanges() {
        int updated = audioEnqueueService.completeSuccess(
                task.getId(), token, cache.getId(), "voc/tts/1/voice.mp3");

        assertThat(updated).isEqualTo(1);

        AudioTask reloadedTask = audioTaskRepository.findById(task.getId()).orElseThrow();
        AudioCache reloadedCache = audioCacheRepository.findById(cache.getId()).orElseThrow();

        assertThat(reloadedTask.getStatus()).isEqualTo(AudioTaskStatus.SUCCEEDED);
        assertThat(reloadedCache.getStatus()).isEqualTo(AudioCacheStatus.READY);
        assertThat(reloadedCache.getB2ObjectKey()).isEqualTo("voc/tts/1/voice.mp3");
    }
}
