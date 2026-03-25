package com.jlpt_mono.app.service;

import com.jlpt_mono.app.dto.WordDetailResponse;
import com.jlpt_mono.app.dto.WordSummaryResponse;
import com.jlpt_mono.app.entity.Category;
import com.jlpt_mono.app.entity.Example;
import com.jlpt_mono.app.entity.Word;
import com.jlpt_mono.app.entity.WordRelation;
import com.jlpt_mono.app.exception.ResourceNotFoundException;
import com.jlpt_mono.app.repository.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.jpa.domain.Specification;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class VocabularyServiceTest {

    @Mock
    private WordRepository wordRepository;
    @Mock
    private ExampleRepository exampleRepository;
    @Mock
    private WordRelationRepository wordRelationRepository;
    @Mock
    private CategoryRepository categoryRepository;

    private VocabularyService vocabularyService;

    @BeforeEach
    void setUp() {
        vocabularyService = new VocabularyService(
                wordRepository, exampleRepository, wordRelationRepository, categoryRepository);
    }

    private Word createTestWord() {
        Word word = new Word();
        word.setId(1L);
        word.setKanji("食べる");
        word.setHiragana("たべる");
        word.setDefinitionZh("吃、食用");
        word.setDefinitionEn("to eat");
        word.setPartOfSpeech("verb");
        word.setVerbType("ichidan");
        word.setJlptLevel("N5");
        return word;
    }

    @Test
    @DisplayName("搜尋單字：應回傳分頁結果")
    @SuppressWarnings("unchecked")
    void searchWords_returnsPagedResults() {
        Word word = createTestWord();
        var pageable = PageRequest.of(0, 20);
        var page = new PageImpl<>(List.of(word), pageable, 1);

        when(wordRepository.findAll(any(Specification.class), eq(pageable))).thenReturn(page);

        Page<WordSummaryResponse> result = vocabularyService.searchWords("N5", null, null, null, pageable);

        assertThat(result.getTotalElements()).isEqualTo(1);
        assertThat(result.getContent().getFirst().getKanji()).isEqualTo("食べる");
        assertThat(result.getContent().getFirst().getJlptLevel()).isEqualTo("N5");
    }

    @Test
    @DisplayName("搜尋單字：無結果時應回傳空頁")
    @SuppressWarnings("unchecked")
    void searchWords_emptyResults() {
        var pageable = PageRequest.of(0, 20);
        when(wordRepository.findAll(any(Specification.class), eq(pageable)))
                .thenReturn(Page.empty(pageable));

        Page<WordSummaryResponse> result = vocabularyService.searchWords("N1", null, null, null, pageable);

        assertThat(result.getTotalElements()).isZero();
        assertThat(result.getContent()).isEmpty();
    }

    @Test
    @DisplayName("取得單字詳情：應包含例句和關聯詞")
    void getWordDetail_withExamplesAndRelations() {
        Word word = createTestWord();
        when(wordRepository.findWithCategoryById(1L)).thenReturn(Optional.of(word));

        Example example = new Example();
        example.setId(1L);
        example.setSentenceJp("朝ごはんを食べる。");
        example.setSentenceZh("吃早餐。");
        example.setSentenceEn("I eat breakfast.");
        when(exampleRepository.findByWordId(1L)).thenReturn(List.of(example));

        Word relatedWord = new Word();
        relatedWord.setId(2L);
        relatedWord.setKanji("飲む");
        relatedWord.setHiragana("のむ");
        relatedWord.setDefinitionZh("喝");
        relatedWord.setDefinitionEn("to drink");

        WordRelation relation = new WordRelation();
        relation.setId(1L);
        relation.setWord(word);
        relation.setRelatedWord(relatedWord);
        relation.setRelationType("synonym");
        when(wordRelationRepository.findWithRelatedWordByWordId(1L)).thenReturn(List.of(relation));

        WordDetailResponse result = vocabularyService.getWordDetail(1L);

        assertThat(result.getKanji()).isEqualTo("食べる");
        assertThat(result.getExamples()).hasSize(1);
        assertThat(result.getExamples().getFirst().getSentenceJp()).isEqualTo("朝ごはんを食べる。");
        assertThat(result.getRelations()).hasSize(1);
        assertThat(result.getRelations().getFirst().getKanji()).isEqualTo("飲む");
        assertThat(result.getRelations().getFirst().getRelationType()).isEqualTo("synonym");
    }

    @Test
    @DisplayName("取得單字詳情：ID 不存在時應拋出 ResourceNotFoundException")
    void getWordDetail_notFound() {
        when(wordRepository.findWithCategoryById(999L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> vocabularyService.getWordDetail(999L))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessageContaining("Word not found");
    }

    @Test
    @DisplayName("取得分類樹：應回傳階層結構")
    void getCategoryTree_returnsHierarchy() {
        Category parent = new Category();
        parent.setId(1L);
        parent.setNameJp("食べ物");
        parent.setNameZh("食物");
        parent.setNameEn("Food");

        Category child = new Category();
        child.setId(2L);
        child.setNameJp("果物");
        child.setNameZh("水果");
        child.setNameEn("Fruits");
        child.setParent(parent);

        when(categoryRepository.findAll()).thenReturn(List.of(parent, child));

        var result = vocabularyService.getCategoryTree();

        assertThat(result).hasSize(1);
        assertThat(result.getFirst().getNameEn()).isEqualTo("Food");
        assertThat(result.getFirst().getChildren()).hasSize(1);
        assertThat(result.getFirst().getChildren().getFirst().getNameEn()).isEqualTo("Fruits");
    }
}
