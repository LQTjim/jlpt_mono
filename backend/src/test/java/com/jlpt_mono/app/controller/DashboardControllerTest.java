package com.jlpt_mono.app.controller;

import com.jlpt_mono.app.config.SecurityConfig;
import com.jlpt_mono.app.dto.DashboardSummaryResponse;
import com.jlpt_mono.app.dto.QuizHistoryResponse;
import com.jlpt_mono.app.security.JwtAuthenticationFilter;
import com.jlpt_mono.app.security.JwtTokenProvider;
import com.jlpt_mono.app.service.DashboardService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.util.List;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(DashboardController.class)
@Import({SecurityConfig.class, JwtAuthenticationFilter.class})
class DashboardControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private DashboardService dashboardService;

    @MockitoBean
    private JwtTokenProvider jwtTokenProvider;

    private void setupAuth() {
        when(jwtTokenProvider.validateToken("valid-jwt")).thenReturn(true);
        when(jwtTokenProvider.getUserIdFromToken("valid-jwt")).thenReturn(1L);
    }

    @Test
    @DisplayName("GET /api/dashboard/summary 應回傳統計資料")
    void getSummary_success() throws Exception {
        setupAuth();

        var response = DashboardSummaryResponse.builder()
                .totalQuizzes(10)
                .averageScore(85)
                .currentStreak(3)
                .recentQuizzes(List.of(
                        QuizHistoryResponse.builder()
                                .sessionId(1L)
                                .jlptLevel("N5")
                                .score(9)
                                .total(10)
                                .completedAt(Instant.parse("2026-03-30T10:00:00Z"))
                                .build()
                ))
                .build();

        when(dashboardService.getSummary(1L)).thenReturn(response);

        mockMvc.perform(get("/api/dashboard/summary")
                        .header("Authorization", "Bearer valid-jwt"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalQuizzes").value(10))
                .andExpect(jsonPath("$.averageScore").value(85))
                .andExpect(jsonPath("$.currentStreak").value(3))
                .andExpect(jsonPath("$.recentQuizzes[0].sessionId").value(1))
                .andExpect(jsonPath("$.recentQuizzes[0].score").value(9));
    }

    @Test
    @DisplayName("GET /api/dashboard/summary 無認證時應回傳 401")
    void getSummary_unauthenticated() throws Exception {
        mockMvc.perform(get("/api/dashboard/summary"))
                .andExpect(status().isUnauthorized());
    }
}
