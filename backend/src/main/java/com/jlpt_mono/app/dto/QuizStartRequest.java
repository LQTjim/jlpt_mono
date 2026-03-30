package com.jlpt_mono.app.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class QuizStartRequest {

    @NotBlank
    @Pattern(regexp = "N[1-5]", message = "jlptLevel must be N1-N5")
    private String jlptLevel;

    @NotBlank
    @Pattern(regexp = "MEANING|REVERSE|SENTENCE_FILL",
            message = "questionType must be MEANING, REVERSE, or SENTENCE_FILL")
    private String questionType;

    @NotBlank
    @Pattern(regexp = "zh|en", message = "locale must be zh or en")
    private String locale;
}
