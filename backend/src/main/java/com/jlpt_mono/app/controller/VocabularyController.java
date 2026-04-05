package com.jlpt_mono.app.controller;

import com.jlpt_mono.app.dto.CategoryResponse;
import com.jlpt_mono.app.dto.PageResponse;
import com.jlpt_mono.app.dto.WordDetailResponse;
import com.jlpt_mono.app.dto.WordSummaryResponse;
import com.jlpt_mono.app.service.VocabularyService;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/vocabulary")
public class VocabularyController {

    private final VocabularyService vocabularyService;

    public VocabularyController(VocabularyService vocabularyService) {
        this.vocabularyService = vocabularyService;
    }

    @GetMapping
    public ResponseEntity<PageResponse<WordSummaryResponse>> searchWords(
            @RequestParam(required = false) String jlptLevel,
            @RequestParam(required = false) String partOfSpeech,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String keyword,
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.ASC) Pageable pageable) {
        return ResponseEntity.ok(PageResponse.from(
                vocabularyService.searchWords(jlptLevel, partOfSpeech, categoryId, keyword, pageable)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<WordDetailResponse> getWordDetail(@PathVariable Long id) {
        return ResponseEntity.ok(vocabularyService.getWordDetail(id));
    }

    @GetMapping("/flashcards/random")
    public ResponseEntity<List<WordSummaryResponse>> getRandomFlashcards(
            @RequestParam String jlptLevel,
            @RequestParam(defaultValue = "20") int count) {
        return ResponseEntity.ok(vocabularyService.getRandomFlashcards(jlptLevel, count));
    }

    @GetMapping("/categories")
    public ResponseEntity<List<CategoryResponse>> getCategories() {
        return ResponseEntity.ok(vocabularyService.getCategoryTree());
    }
}
