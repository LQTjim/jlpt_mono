package com.jlpt_mono.app.dto;

import com.jlpt_mono.app.entity.Word;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class WordDetailResponse {
    private Long id;
    private String kanji;
    private String hiragana;
    private String romaji;
    private String definitionZh;
    private String definitionEn;
    private String partOfSpeech;
    private String verbType;
    private String jlptLevel;
    private Short difficultyScore;
    private Integer frequencyRank;
    private String notes;
    private CategoryResponse category;
    private List<ExampleResponse> examples;
    private List<RelatedWordResponse> relations;

    public static WordDetailResponse from(Word word, List<ExampleResponse> examples, List<RelatedWordResponse> relations) {
        var builder = WordDetailResponse.builder()
                .id(word.getId())
                .kanji(word.getKanji())
                .hiragana(word.getHiragana())
                .romaji(word.getRomaji())
                .definitionZh(word.getDefinitionZh())
                .definitionEn(word.getDefinitionEn())
                .partOfSpeech(word.getPartOfSpeech())
                .verbType(word.getVerbType())
                .jlptLevel(word.getJlptLevel())
                .difficultyScore(word.getDifficultyScore())
                .frequencyRank(word.getFrequencyRank())
                .notes(word.getNotes())
                .examples(examples)
                .relations(relations);

        if (word.getCategory() != null) {
            builder.category(CategoryResponse.from(word.getCategory()));
        }

        return builder.build();
    }
}
