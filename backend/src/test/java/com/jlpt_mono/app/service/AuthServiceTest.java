package com.jlpt_mono.app.service;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.jlpt_mono.app.dto.AuthResponse;
import com.jlpt_mono.app.entity.RefreshToken;
import com.jlpt_mono.app.entity.User;
import com.jlpt_mono.app.exception.AuthException;
import com.jlpt_mono.app.repository.UserRepository;
import com.jlpt_mono.app.security.JwtTokenProvider;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private JwtTokenProvider jwtTokenProvider;

    @Mock
    private RefreshTokenService refreshTokenService;

    @Mock
    private GoogleIdTokenVerifier googleVerifier;

    private AuthService authService;

    private User testUser;

    @BeforeEach
    void setUp() {
        authService = new AuthService(userRepository, jwtTokenProvider, refreshTokenService, googleVerifier);

        testUser = new User();
        testUser.setId(1L);
        testUser.setEmail("test@example.com");
        testUser.setName("Test User");
        testUser.setPictureUrl("https://example.com/pic.jpg");
        testUser.setGoogleId("google-123");
    }

    @Test
    @DisplayName("Google 登入：新用戶應建立帳號並回傳 tokens")
    void authenticateWithGoogle_newUser() throws Exception {
        // 準備 mock Google token
        GoogleIdToken mockIdToken = mock(GoogleIdToken.class);
        GoogleIdToken.Payload payload = mock(GoogleIdToken.Payload.class);
        when(mockIdToken.getPayload()).thenReturn(payload);
        when(payload.getSubject()).thenReturn("google-123");
        when(payload.getEmail()).thenReturn("test@example.com");
        when(payload.get("name")).thenReturn("Test User");
        when(payload.get("picture")).thenReturn("https://example.com/pic.jpg");

        when(googleVerifier.verify("valid-id-token")).thenReturn(mockIdToken);
        when(userRepository.findByGoogleId("google-123")).thenReturn(Optional.empty());
        when(userRepository.save(any(User.class))).thenReturn(testUser);
        when(jwtTokenProvider.generateToken(testUser)).thenReturn("access-token");

        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setToken("refresh-token");
        when(refreshTokenService.createRefreshToken(testUser)).thenReturn(refreshToken);

        AuthResponse response = authService.authenticateWithGoogle("valid-id-token");

        assertThat(response.getAccessToken()).isEqualTo("access-token");
        assertThat(response.getRefreshToken()).isEqualTo("refresh-token");
        assertThat(response.getEmail()).isEqualTo("test@example.com");
        verify(userRepository).save(any(User.class));
    }

    @Test
    @DisplayName("Google 登入：既有用戶應更新 name 和 picture 並回傳 tokens")
    void authenticateWithGoogle_existingUser() throws Exception {
        GoogleIdToken mockIdToken = mock(GoogleIdToken.class);
        GoogleIdToken.Payload payload = mock(GoogleIdToken.Payload.class);
        when(mockIdToken.getPayload()).thenReturn(payload);
        when(payload.getSubject()).thenReturn("google-123");
        when(payload.getEmail()).thenReturn("test@example.com");
        when(payload.get("name")).thenReturn("Updated Name");
        when(payload.get("picture")).thenReturn("https://example.com/new-pic.jpg");

        when(googleVerifier.verify("valid-id-token")).thenReturn(mockIdToken);
        when(userRepository.findByGoogleId("google-123")).thenReturn(Optional.of(testUser));
        when(userRepository.save(testUser)).thenReturn(testUser);
        when(jwtTokenProvider.generateToken(testUser)).thenReturn("access-token");

        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setToken("refresh-token");
        when(refreshTokenService.createRefreshToken(testUser)).thenReturn(refreshToken);

        authService.authenticateWithGoogle("valid-id-token");

        // 驗證 name 和 picture 被更新
        verify(userRepository).save(testUser);
        assertThat(testUser.getName()).isEqualTo("Updated Name");
        assertThat(testUser.getPictureUrl()).isEqualTo("https://example.com/new-pic.jpg");
    }

    @Test
    @DisplayName("Google 登入：無效的 Google token 應拋出 AuthException")
    void authenticateWithGoogle_invalidToken() throws Exception {
        when(googleVerifier.verify("invalid-token")).thenReturn(null);

        assertThatThrownBy(() -> authService.authenticateWithGoogle("invalid-token"))
                .isInstanceOf(AuthException.class)
                .hasMessageContaining("Invalid");
    }

    @Test
    @DisplayName("刷新 token：應刪除舊 token 並回傳新的 access token 和 refresh token")
    void refreshAccessToken() {
        RefreshToken oldToken = new RefreshToken();
        oldToken.setToken("old-refresh");
        oldToken.setUser(testUser);

        RefreshToken newToken = new RefreshToken();
        newToken.setToken("new-refresh");

        when(refreshTokenService.verifyAndDeleteRefreshToken("old-refresh")).thenReturn(oldToken);
        when(refreshTokenService.createRefreshToken(testUser)).thenReturn(newToken);
        when(jwtTokenProvider.generateToken(testUser)).thenReturn("new-access");

        AuthResponse response = authService.refreshAccessToken("old-refresh");

        assertThat(response.getAccessToken()).isEqualTo("new-access");
        assertThat(response.getRefreshToken()).isEqualTo("new-refresh");
        verify(refreshTokenService).verifyAndDeleteRefreshToken("old-refresh");
        verify(refreshTokenService).createRefreshToken(testUser);
    }
}
