package com.jlpt_mono.app.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

import java.util.List;
import java.util.Set;

@Data
public class QuizStartRequest {

    private static final Set<String> VALID_TYPES = Set.of("MEANING", "REVERSE", "SENTENCE_FILL");

    @NotBlank
    @Pattern(regexp = "N[1-5]", message = "jlptLevel must be N1-N5")
    private String jlptLevel;

    @NotEmpty
    private List<@NotNull @Pattern(regexp = "MEANING|REVERSE|SENTENCE_FILL",
            message = "questionTypes must be MEANING, REVERSE, or SENTENCE_FILL") String> questionTypes;
}
