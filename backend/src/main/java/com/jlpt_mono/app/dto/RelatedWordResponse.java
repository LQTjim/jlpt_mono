package com.jlpt_mono.app.dto;

import com.jlpt_mono.app.entity.WordRelation;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RelatedWordResponse {
    private Long id;
    private String kanji;
    private String hiragana;
    private String definitionZh;
    private String definitionEn;
    private String relationType;

    public static RelatedWordResponse from(WordRelation relation) {
        var related = relation.getRelatedWord();
        return RelatedWordResponse.builder()
                .id(related.getId())
                .kanji(related.getKanji())
                .hiragana(related.getHiragana())
                .definitionZh(related.getDefinitionZh())
                .definitionEn(related.getDefinitionEn())
                .relationType(relation.getRelationType())
                .build();
    }
}
