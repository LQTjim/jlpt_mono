package com.jlpt_mono.app.controller;

import com.jlpt_mono.app.config.SecurityConfig;
import com.jlpt_mono.app.dto.AudioResponse;
import com.jlpt_mono.app.exception.ResourceNotFoundException;
import com.jlpt_mono.app.security.JwtAuthenticationFilter;
import com.jlpt_mono.app.security.JwtTokenProvider;
import com.jlpt_mono.app.service.AudioService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(AudioController.class)
@Import({SecurityConfig.class, JwtAuthenticationFilter.class})
class AudioControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private AudioService audioService;

    @MockitoBean
    private JwtTokenProvider jwtTokenProvider;

    private void setupAuth() {
        when(jwtTokenProvider.validateToken("valid-jwt")).thenReturn(true);
        when(jwtTokenProvider.getUserIdFromToken("valid-jwt")).thenReturn(1L);
    }

    @Test
    @DisplayName("POST /api/audio/generate/{id} 無認證時應回傳 401")
    void generate_unauthenticated() throws Exception {
        mockMvc.perform(post("/api/audio/generate/1"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("POST /api/audio/generate/{id} cache 已 READY 時應回傳 200 含 presignedUrl")
    void generate_cacheReady_returns200() throws Exception {
        setupAuth();
        Instant expiresAt = Instant.now().plusSeconds(900);
        when(audioService.generateAudio(1L))
                .thenReturn(AudioResponse.ready(10L, "https://presigned.url/audio.mp3", expiresAt));

        mockMvc.perform(post("/api/audio/generate/1")
                        .header("Authorization", "Bearer valid-jwt"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("READY"))
                .andExpect(jsonPath("$.jobId").value(10))
                .andExpect(jsonPath("$.presignedUrl").value("https://presigned.url/audio.mp3"));
    }

    @Test
    @DisplayName("POST /api/audio/generate/{id} cache 不存在時應回傳 202")
    void generate_newJob_returns202() throws Exception {
        setupAuth();
        when(audioService.generateAudio(1L))
                .thenReturn(AudioResponse.inProgress(10L, "PENDING"));

        mockMvc.perform(post("/api/audio/generate/1")
                        .header("Authorization", "Bearer valid-jwt"))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.status").value("PENDING"))
                .andExpect(jsonPath("$.jobId").value(10))
                .andExpect(jsonPath("$.presignedUrl").doesNotExist());
    }

    @Test
    @DisplayName("POST /api/audio/generate/{id} race-recovery 回傳 FAILED 時應回傳 200")
    void generate_failedTerminal_returns200() throws Exception {
        setupAuth();
        when(audioService.generateAudio(1L))
                .thenReturn(AudioResponse.failed(10L, "TTS API error: 401"));

        mockMvc.perform(post("/api/audio/generate/1")
                        .header("Authorization", "Bearer valid-jwt"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("FAILED"))
                .andExpect(jsonPath("$.errorMessage").value("TTS API error: 401"));
    }

    @Test
    @DisplayName("POST /api/audio/generate/{id} vocabularyId 不存在時應回傳 404")
    void generate_wordNotFound_returns404() throws Exception {
        setupAuth();
        when(audioService.generateAudio(999L))
                .thenThrow(new ResourceNotFoundException("Word not found: 999"));

        mockMvc.perform(post("/api/audio/generate/999")
                        .header("Authorization", "Bearer valid-jwt"))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("GET /api/audio/status/{jobId} READY 時應回傳 200 含 presignedUrl")
    void status_ready_returns200() throws Exception {
        setupAuth();
        Instant expiresAt = Instant.now().plusSeconds(900);
        when(audioService.getStatus(10L))
                .thenReturn(AudioResponse.ready(10L, "https://presigned.url/audio.mp3", expiresAt));

        mockMvc.perform(get("/api/audio/status/10")
                        .header("Authorization", "Bearer valid-jwt"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("READY"))
                .andExpect(jsonPath("$.presignedUrl").value("https://presigned.url/audio.mp3"));
    }

    @Test
    @DisplayName("GET /api/audio/status/{jobId} PROCESSING 時應回傳 200 含 status")
    void status_processing_returns200() throws Exception {
        setupAuth();
        when(audioService.getStatus(10L))
                .thenReturn(AudioResponse.inProgress(10L, "PROCESSING"));

        mockMvc.perform(get("/api/audio/status/10")
                        .header("Authorization", "Bearer valid-jwt"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("PROCESSING"))
                .andExpect(jsonPath("$.presignedUrl").doesNotExist());
    }

    @Test
    @DisplayName("GET /api/audio/status/{jobId} job 不存在時應回傳 404")
    void status_notFound_returns404() throws Exception {
        setupAuth();
        when(audioService.getStatus(999L))
                .thenThrow(new ResourceNotFoundException("Audio job not found: 999"));

        mockMvc.perform(get("/api/audio/status/999")
                        .header("Authorization", "Bearer valid-jwt"))
                .andExpect(status().isNotFound());
    }
}
