package com.jlpt_mono.app.service;

import com.jlpt_mono.app.config.CacheConfig;
import com.jlpt_mono.app.dto.CategoryResponse;
import com.jlpt_mono.app.entity.Category;
import com.jlpt_mono.app.repository.CategoryRepository;
import com.jlpt_mono.app.repository.ExampleRepository;
import com.jlpt_mono.app.repository.WordRelationRepository;
import com.jlpt_mono.app.repository.WordRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

@SpringBootTest(classes = {VocabularyService.class, CacheConfig.class})
class VocabularyCacheTest {

    @Autowired
    private VocabularyService vocabularyService;

    @MockitoBean
    private WordRepository wordRepository;
    @MockitoBean
    private ExampleRepository exampleRepository;
    @MockitoBean
    private WordRelationRepository wordRelationRepository;
    @MockitoBean
    private CategoryRepository categoryRepository;

    @Test
    @DisplayName("getCategoryTree 第二次呼叫應 hit cache，不再查 DB")
    void getCategoryTree_cacheHit() {
        Category cat = new Category();
        cat.setId(1L);
        cat.setNameEn("Food");
        when(categoryRepository.findAll()).thenReturn(List.of(cat));

        List<CategoryResponse> first = vocabularyService.getCategoryTree();
        List<CategoryResponse> second = vocabularyService.getCategoryTree();

        verify(categoryRepository, times(1)).findAll();
        assertThat(first).hasSize(1);
        assertThat(second).hasSize(1);
    }
}
