package com.jlpt_mono.app.dto;

import com.jlpt_mono.app.entity.Example;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ExampleResponse {
    private Long id;
    private String sentenceJp;
    private String sentenceZh;
    private String sentenceEn;

    public static ExampleResponse from(Example example) {
        return ExampleResponse.builder()
                .id(example.getId())
                .sentenceJp(example.getSentenceJp())
                .sentenceZh(example.getSentenceZh())
                .sentenceEn(example.getSentenceEn())
                .build();
    }
}
