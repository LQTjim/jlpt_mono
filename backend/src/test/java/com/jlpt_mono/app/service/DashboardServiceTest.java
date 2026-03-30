package com.jlpt_mono.app.service;

import com.jlpt_mono.app.dto.DashboardSummaryResponse;
import com.jlpt_mono.app.repository.QuizSessionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class DashboardServiceTest {

    @Mock
    private QuizSessionRepository quizSessionRepository;

    private DashboardService dashboardService;

    @BeforeEach
    void setUp() {
        dashboardService = new DashboardService(quizSessionRepository);
    }

    @Test
    @DisplayName("getSummary 應回傳統計和最近成績")
    void getSummary_returnsStats() {
        when(quizSessionRepository.countByUserIdAndCompletedAtIsNotNull(1L)).thenReturn(5L);
        when(quizSessionRepository.findAverageScorePercentageByUserId(1L)).thenReturn(82.5);
        when(quizSessionRepository.findCurrentStreakByUserId(1L)).thenReturn(2);
        when(quizSessionRepository.findByUserIdAndCompletedAtIsNotNullOrderByCompletedAtDesc(eq(1L), any()))
                .thenReturn(new PageImpl<>(List.of(), PageRequest.of(0, 3), 0));

        DashboardSummaryResponse result = dashboardService.getSummary(1L);

        assertThat(result.getTotalQuizzes()).isEqualTo(5);
        assertThat(result.getAverageScore()).isEqualTo(83);
        assertThat(result.getCurrentStreak()).isEqualTo(2);
        assertThat(result.getRecentQuizzes()).isEmpty();
    }

    @Test
    @DisplayName("getSummary 無紀錄時應回傳零值")
    void getSummary_noHistory() {
        when(quizSessionRepository.countByUserIdAndCompletedAtIsNotNull(1L)).thenReturn(0L);
        when(quizSessionRepository.findAverageScorePercentageByUserId(1L)).thenReturn(0.0);
        when(quizSessionRepository.findCurrentStreakByUserId(1L)).thenReturn(0);
        when(quizSessionRepository.findByUserIdAndCompletedAtIsNotNullOrderByCompletedAtDesc(eq(1L), any()))
                .thenReturn(new PageImpl<>(List.of(), PageRequest.of(0, 3), 0));

        DashboardSummaryResponse result = dashboardService.getSummary(1L);

        assertThat(result.getTotalQuizzes()).isZero();
        assertThat(result.getAverageScore()).isZero();
        assertThat(result.getCurrentStreak()).isZero();
    }
}
