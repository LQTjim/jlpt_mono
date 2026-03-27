package com.jlpt_mono.app.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class QuizSubmitResponse {

    private Long sessionId;
    private int score;
    private int total;
    private List<ResultItem> results;

    @Data
    @Builder
    public static class ResultItem {
        private Long questionId;
        private boolean correct;
        private String correctKey;
        private String selectedKey;
    }
}
