package com.jlpt_mono.app.dto;

import com.jlpt_mono.app.entity.QuizSession;
import lombok.Builder;
import lombok.Data;

import java.time.Instant;

@Data
@Builder
public class QuizHistoryResponse {

    private Long sessionId;
    private String jlptLevel;
    private int score;
    private int total;
    private Instant completedAt;

    public static QuizHistoryResponse from(QuizSession session) {
        return QuizHistoryResponse.builder()
                .sessionId(session.getId())
                .jlptLevel(session.getJlptLevel())
                .score(session.getScore() != null ? session.getScore() : 0)
                .total(session.getTotal())
                .completedAt(session.getCompletedAt())
                .build();
    }
}
