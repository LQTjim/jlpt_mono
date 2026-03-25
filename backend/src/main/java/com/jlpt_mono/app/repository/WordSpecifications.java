package com.jlpt_mono.app.repository;

import com.jlpt_mono.app.entity.Word;
import org.springframework.data.jpa.domain.Specification;

public final class WordSpecifications {

    private WordSpecifications() {}

    public static Specification<Word> hasJlptLevel(String jlptLevel) {
        return (root, query, cb) -> cb.equal(root.get("jlptLevel"), jlptLevel);
    }

    public static Specification<Word> hasPartOfSpeech(String partOfSpeech) {
        return (root, query, cb) -> cb.equal(root.get("partOfSpeech"), partOfSpeech);
    }

    public static Specification<Word> hasCategoryId(Long categoryId) {
        return (root, query, cb) -> cb.equal(root.get("category").get("id"), categoryId);
    }

    public static Specification<Word> containsKeyword(String keyword) {
        return (root, query, cb) -> {
            String escaped = keyword.toLowerCase()
                    .replace("\\", "\\\\")
                    .replace("%", "\\%")
                    .replace("_", "\\_");
            String pattern = "%" + escaped + "%";
            return cb.or(
                    cb.like(cb.lower(root.get("kanji")), pattern),
                    cb.like(cb.lower(root.get("hiragana")), pattern),
                    cb.like(cb.lower(root.get("romaji")), pattern),
                    cb.like(cb.lower(root.get("definitionZh")), pattern),
                    cb.like(cb.lower(root.get("definitionEn")), pattern)
            );
        };
    }
}
