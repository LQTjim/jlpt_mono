package com.jlpt_mono.app.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class DashboardSummaryResponse {

    private long totalQuizzes;
    private int averageScore;
    private int currentStreak;
    private List<QuizHistoryResponse> recentQuizzes;
}
