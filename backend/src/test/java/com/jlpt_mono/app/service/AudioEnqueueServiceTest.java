package com.jlpt_mono.app.service;

import com.jlpt_mono.app.repository.AudioCacheRepository;
import com.jlpt_mono.app.repository.AudioTaskRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InOrder;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AudioEnqueueServiceTest {

    @Mock private AudioCacheRepository audioCacheRepository;
    @Mock private AudioTaskRepository audioTaskRepository;

    private AudioEnqueueService service;

    private final UUID token = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new AudioEnqueueService(audioCacheRepository, audioTaskRepository);
    }

    @Test
    @DisplayName("completeSuccess — 成功時應依序呼叫 completeTask 再 markReady")
    void completeSuccess_success_callsBothInOrder() {
        when(audioTaskRepository.completeTask(eq(10L), eq(token), any())).thenReturn(1);

        int result = service.completeSuccess(10L, token, 1L, "voc/tts/1/voice.mp3");

        assertThat(result).isEqualTo(1);
        InOrder order = inOrder(audioTaskRepository, audioCacheRepository);
        order.verify(audioTaskRepository).completeTask(eq(10L), eq(token), any());
        order.verify(audioCacheRepository).markReady(eq(1L), eq("voc/tts/1/voice.mp3"), any());
    }

    @Test
    @DisplayName("completeSuccess — ownership 丟失（completeTask 回 0）時應跳過 markReady，不產生 SUCCEEDED + READY 半更新")
    void completeSuccess_ownershipLost_skipsMarkReady() {
        when(audioTaskRepository.completeTask(eq(10L), eq(token), any())).thenReturn(0);

        int result = service.completeSuccess(10L, token, 1L, "voc/tts/1/voice.mp3");

        assertThat(result).isEqualTo(0);
        verifyNoInteractions(audioCacheRepository);
    }

    @Test
    @DisplayName("completeSuccess — markReady 拋出例外時應傳播，讓 @Transactional rollback completeTask（task 維持 CLAIMED）")
    void completeSuccess_markReadyThrows_exceptionPropagatesForTransactionRollback() {
        when(audioTaskRepository.completeTask(eq(10L), eq(token), any())).thenReturn(1);
        doThrow(new RuntimeException("DB connection lost"))
                .when(audioCacheRepository).markReady(any(), any(), any());

        // Exception must propagate — swallowing it would leave task=SUCCEEDED, cache=PROCESSING (stuck state)
        assertThatThrownBy(() -> service.completeSuccess(10L, token, 1L, "voc/tts/1/voice.mp3"))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("DB connection lost");

        // completeTask ran before the throw; @Transactional rolls it back on exception propagation
        verify(audioTaskRepository).completeTask(eq(10L), eq(token), any());
    }

    @Test
    @DisplayName("completeSuccess は @Transactional で宣言されていること — annotation 缺失は SUCCEEDED+PROCESSING stuck-state の再発を招く")
    void completeSuccess_isAnnotatedTransactional() throws NoSuchMethodException {
        // If @Transactional is removed, completeTask and markReady run in separate auto-transactions.
        // A markReady failure would leave task=SUCCEEDED + cache=PROCESSING with no active task,
        // which recovery never picks up. This check guards against that regression.
        var method = AudioEnqueueService.class.getDeclaredMethod(
                "completeSuccess", Long.class, UUID.class, Long.class, String.class);
        assertThat(method.isAnnotationPresent(Transactional.class))
                .as("completeSuccess must be @Transactional so completeTask and markReady " +
                    "commit or roll back together, preventing the SUCCEEDED+PROCESSING stuck state")
                .isTrue();
    }
}
