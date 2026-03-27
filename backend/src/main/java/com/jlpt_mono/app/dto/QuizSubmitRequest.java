package com.jlpt_mono.app.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

import java.util.List;

@Data
public class QuizSubmitRequest {

    @NotNull
    private List<@NotNull @Valid AnswerItem> answers;

    @Data
    public static class AnswerItem {
        @NotNull
        private Long questionId;

        @Pattern(regexp = "[A-D]", message = "selectedKey must be A, B, C, or D")
        private String selectedKey;
    }
}
