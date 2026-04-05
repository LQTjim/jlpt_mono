package com.jlpt_mono.app.service;

import com.jlpt_mono.app.dto.*;
import com.jlpt_mono.app.entity.Category;
import com.jlpt_mono.app.entity.Word;
import com.jlpt_mono.app.exception.ResourceNotFoundException;
import com.jlpt_mono.app.repository.*;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@Transactional(readOnly = true)
public class VocabularyService {

    private final WordRepository wordRepository;
    private final ExampleRepository exampleRepository;
    private final WordRelationRepository wordRelationRepository;
    private final CategoryRepository categoryRepository;

    public VocabularyService(WordRepository wordRepository,
            ExampleRepository exampleRepository,
            WordRelationRepository wordRelationRepository,
            CategoryRepository categoryRepository) {
        this.wordRepository = wordRepository;
        this.exampleRepository = exampleRepository;
        this.wordRelationRepository = wordRelationRepository;
        this.categoryRepository = categoryRepository;
    }

    public Page<WordSummaryResponse> searchWords(String jlptLevel, String partOfSpeech,
            Long categoryId, String keyword,
            Pageable pageable) {
        Specification<Word> spec = (root, query, cb) -> cb.conjunction();

        if (jlptLevel != null && !jlptLevel.isBlank()) {
            spec = spec.and(WordSpecifications.hasJlptLevel(jlptLevel.trim()));
        }
        if (partOfSpeech != null && !partOfSpeech.isBlank()) {
            spec = spec.and(WordSpecifications.hasPartOfSpeech(partOfSpeech.trim()));
        }
        if (categoryId != null) {
            spec = spec.and(WordSpecifications.hasCategoryId(categoryId));
        }
        if (keyword != null && !keyword.isBlank()) {
            spec = spec.and(WordSpecifications.containsKeyword(keyword.trim()));
        }

        return wordRepository.findAll(spec, pageable).map(WordSummaryResponse::from);
    }

    public WordDetailResponse getWordDetail(Long id) {
        Word word = wordRepository.findWithCategoryById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Word not found: " + id));

        List<ExampleResponse> examples = exampleRepository.findByWordId(id).stream()
                .map(ExampleResponse::from)
                .toList();

        List<RelatedWordResponse> relations = wordRelationRepository.findWithRelatedWordByWordId(id).stream()
                .map(RelatedWordResponse::from)
                .toList();

        return WordDetailResponse.from(word, examples, relations);
    }

    public List<WordSummaryResponse> getRandomFlashcards(String jlptLevel, int count) {
        if (jlptLevel == null || jlptLevel.isBlank()) {
            throw new IllegalArgumentException("jlptLevel is required");
        }
        int safeCount = Math.max(1, Math.min(count, 50));
        return wordRepository.findRandomByJlptLevel(jlptLevel.trim(), safeCount)
                .stream()
                .map(WordSummaryResponse::from)
                .toList();
    }

    @Cacheable("categoryTree")
    public List<CategoryResponse> getCategoryTree() {
        List<Category> all = categoryRepository.findAll();
        Map<Long, CategoryResponse> map = new LinkedHashMap<>();
        List<CategoryResponse> roots = new ArrayList<>();

        for (Category c : all) {
            map.put(c.getId(), CategoryResponse.from(c));
        }
        for (Category c : all) {
            CategoryResponse dto = map.get(c.getId());
            if (c.getParent() == null) {
                roots.add(dto);
            } else {
                CategoryResponse parent = map.get(c.getParent().getId());
                if (parent != null && parent.getChildren() != null) {
                    parent.getChildren().add(dto);
                }
            }
        }
        return roots;
    }
}
