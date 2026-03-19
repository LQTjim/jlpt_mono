package com.jlpt_mono.app.service;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.jlpt_mono.app.dto.AuthResponse;
import com.jlpt_mono.app.entity.RefreshToken;
import com.jlpt_mono.app.entity.User;
import com.jlpt_mono.app.exception.AuthException;
import com.jlpt_mono.app.repository.UserRepository;
import com.jlpt_mono.app.security.JwtTokenProvider;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final JwtTokenProvider jwtTokenProvider;
    private final RefreshTokenService refreshTokenService;
    private final GoogleIdTokenVerifier googleVerifier;

    public AuthService(
            UserRepository userRepository,
            JwtTokenProvider jwtTokenProvider,
            RefreshTokenService refreshTokenService,
            GoogleIdTokenVerifier googleVerifier) {
        this.userRepository = userRepository;
        this.jwtTokenProvider = jwtTokenProvider;
        this.refreshTokenService = refreshTokenService;
        this.googleVerifier = googleVerifier;
    }

    @Transactional
    public AuthResponse authenticateWithGoogle(String idTokenString) {
        GoogleIdToken idToken;
        try {
            idToken = googleVerifier.verify(idTokenString);
        } catch (Exception e) {
            throw new AuthException("Failed to verify Google token", e);
        }

        if (idToken == null) {
            throw new AuthException("Invalid Google ID token");
        }

        GoogleIdToken.Payload payload = idToken.getPayload();
        String googleId = payload.getSubject();
        String email = payload.getEmail();
        String name = (String) payload.get("name");
        String pictureUrl = (String) payload.get("picture");

        User user = userRepository.findByGoogleId(googleId)
                .map(existing -> {
                    existing.setName(name);
                    existing.setPictureUrl(pictureUrl);
                    return userRepository.save(existing);
                })
                .orElseGet(() -> {
                    User newUser = new User();
                    newUser.setEmail(email);
                    newUser.setName(name);
                    newUser.setPictureUrl(pictureUrl);
                    newUser.setGoogleId(googleId);
                    return userRepository.save(newUser);
                });

        String accessToken = jwtTokenProvider.generateToken(user);
        RefreshToken refreshToken = refreshTokenService.createRefreshToken(user);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken.getToken())
                .email(user.getEmail())
                .name(user.getName())
                .pictureUrl(user.getPictureUrl())
                .build();
    }

    @Transactional
    public void logout(String refreshTokenString) {
        refreshTokenService.deleteByToken(refreshTokenString);
    }

    @Transactional
    public AuthResponse refreshAccessToken(String refreshTokenString) {
        RefreshToken oldRefreshToken = refreshTokenService.verifyAndDeleteRefreshToken(refreshTokenString);
        User user = oldRefreshToken.getUser();

        RefreshToken newRefreshToken = refreshTokenService.createRefreshToken(user);

        String newAccessToken = jwtTokenProvider.generateToken(user);

        return AuthResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken.getToken())
                .email(user.getEmail())
                .name(user.getName())
                .pictureUrl(user.getPictureUrl())
                .build();
    }
}
