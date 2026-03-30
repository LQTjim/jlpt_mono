package com.jlpt_mono.app.service;

import com.jlpt_mono.app.dto.DashboardSummaryResponse;
import com.jlpt_mono.app.dto.QuizHistoryResponse;
import com.jlpt_mono.app.repository.QuizSessionRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class DashboardService {

    private static final int RECENT_QUIZZES_LIMIT = 3;

    private final QuizSessionRepository quizSessionRepository;

    public DashboardService(QuizSessionRepository quizSessionRepository) {
        this.quizSessionRepository = quizSessionRepository;
    }

    public DashboardSummaryResponse getSummary(Long userId) {
        long totalQuizzes = quizSessionRepository.countByUserIdAndCompletedAtIsNotNull(userId);
        int averageScore = (int) Math.round(quizSessionRepository.findAverageScorePercentageByUserId(userId));
        int currentStreak = quizSessionRepository.findCurrentStreakByUserId(userId);

        List<QuizHistoryResponse> recentQuizzes = quizSessionRepository
                .findByUserIdAndCompletedAtIsNotNullOrderByCompletedAtDesc(userId, PageRequest.of(0, RECENT_QUIZZES_LIMIT))
                .map(QuizHistoryResponse::from)
                .getContent();

        return DashboardSummaryResponse.builder()
                .totalQuizzes(totalQuizzes)
                .averageScore(averageScore)
                .currentStreak(currentStreak)
                .recentQuizzes(recentQuizzes)
                .build();
    }
}
