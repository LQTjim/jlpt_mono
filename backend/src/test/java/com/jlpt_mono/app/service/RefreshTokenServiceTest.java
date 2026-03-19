package com.jlpt_mono.app.service;

import com.jlpt_mono.app.entity.RefreshToken;
import com.jlpt_mono.app.entity.User;
import com.jlpt_mono.app.exception.AuthException;
import com.jlpt_mono.app.repository.RefreshTokenRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class RefreshTokenServiceTest {

    @Mock
    private RefreshTokenRepository refreshTokenRepository;

    private RefreshTokenService refreshTokenService;

    private User testUser;

    @BeforeEach
    void setUp() {
        // 7 天過期
        refreshTokenService = new RefreshTokenService(refreshTokenRepository, 604800000L);

        testUser = new User();
        testUser.setId(1L);
        testUser.setEmail("test@example.com");
    }

    @Test
    @DisplayName("建立 refresh token 時應產生 UUID 格式的 token 並設定正確的過期時間")
    void createRefreshToken() {
        when(refreshTokenRepository.save(any(RefreshToken.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        RefreshToken result = refreshTokenService.createRefreshToken(testUser);

        assertThat(result.getUser()).isEqualTo(testUser);
        assertThatCode(() -> UUID.fromString(result.getToken())).doesNotThrowAnyException();
        assertThat(result.getExpiresAt()).isAfter(Instant.now());
        assertThat(result.getExpiresAt()).isBefore(Instant.now().plusMillis(604800000L + 1000));

        verify(refreshTokenRepository).save(any(RefreshToken.class));
    }

    @Test
    @DisplayName("驗證有效 token 時應刪除並回傳該 token")
    void verifyAndDeleteValidToken() {
        RefreshToken token = new RefreshToken();
        token.setId(1L);
        token.setToken("valid-token");
        token.setUser(testUser);
        token.setExpiresAt(Instant.now().plusSeconds(3600));

        when(refreshTokenRepository.findByToken("valid-token"))
                .thenReturn(Optional.of(token));

        RefreshToken result = refreshTokenService.verifyAndDeleteRefreshToken("valid-token");

        assertThat(result).isEqualTo(token);
        verify(refreshTokenRepository).delete(token);
    }

    @Test
    @DisplayName("驗證已過期的 token 時應刪除 token 並拋出 AuthException")
    void verifyExpiredToken() {
        RefreshToken token = new RefreshToken();
        token.setId(1L);
        token.setToken("expired-token");
        token.setUser(testUser);
        token.setExpiresAt(Instant.now().minusSeconds(3600));

        when(refreshTokenRepository.findByToken("expired-token"))
                .thenReturn(Optional.of(token));

        assertThatThrownBy(() -> refreshTokenService.verifyAndDeleteRefreshToken("expired-token"))
                .isInstanceOf(AuthException.class)
                .hasMessageContaining("expired");

        verify(refreshTokenRepository).delete(token);
    }

    @Test
    @DisplayName("驗證不存在的 token 時應拋出 AuthException")
    void verifyNonExistentToken() {
        when(refreshTokenRepository.findByToken("nonexistent"))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> refreshTokenService.verifyAndDeleteRefreshToken("nonexistent"))
                .isInstanceOf(AuthException.class)
                .hasMessageContaining("Invalid");

        verify(refreshTokenRepository, never()).delete(any());
    }
}
