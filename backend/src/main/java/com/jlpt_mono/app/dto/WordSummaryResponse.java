package com.jlpt_mono.app.dto;

import com.jlpt_mono.app.entity.Word;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class WordSummaryResponse {
    private Long id;
    private String kanji;
    private String hiragana;
    private String romaji;
    private String definitionZh;
    private String definitionEn;
    private String partOfSpeech;
    private String jlptLevel;

    public static WordSummaryResponse from(Word word) {
        return WordSummaryResponse.builder()
                .id(word.getId())
                .kanji(word.getKanji())
                .hiragana(word.getHiragana())
                .romaji(word.getRomaji())
                .definitionZh(word.getDefinitionZh())
                .definitionEn(word.getDefinitionEn())
                .partOfSpeech(word.getPartOfSpeech())
                .jlptLevel(word.getJlptLevel())
                .build();
    }
}
