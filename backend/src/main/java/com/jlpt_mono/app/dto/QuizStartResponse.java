package com.jlpt_mono.app.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
@Builder
public class QuizStartResponse {

    private Long sessionId;
    private List<QuestionItem> questions;

    @Data
    @Builder
    public static class QuestionItem {
        private Long id;
        private String type;
        private StemItem stem;
        private List<Map<String, String>> options;
    }

    @Data
    @Builder
    public static class StemItem {
        private String kanji;
        private String hiragana;
        private String sentence;
        private String translation;
        private String definitionZh;
        private String definitionEn;
    }
}
