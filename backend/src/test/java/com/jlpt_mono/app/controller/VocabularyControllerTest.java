package com.jlpt_mono.app.controller;

import com.jlpt_mono.app.config.SecurityConfig;
import com.jlpt_mono.app.dto.*;
import com.jlpt_mono.app.security.JwtAuthenticationFilter;
import com.jlpt_mono.app.security.JwtTokenProvider;
import com.jlpt_mono.app.service.VocabularyService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(VocabularyController.class)
@Import({SecurityConfig.class, JwtAuthenticationFilter.class})
class VocabularyControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private VocabularyService vocabularyService;

    @MockitoBean
    private JwtTokenProvider jwtTokenProvider;

    private void setupAuth() {
        when(jwtTokenProvider.validateToken("valid-jwt")).thenReturn(true);
        when(jwtTokenProvider.getUserIdFromToken("valid-jwt")).thenReturn(1L);
    }

    @Test
    @DisplayName("GET /api/vocabulary 無認證時應回傳 401")
    void searchWords_unauthenticated() throws Exception {
        mockMvc.perform(get("/api/vocabulary"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("GET /api/vocabulary 應回傳分頁單字列表")
    void searchWords_success() throws Exception {
        setupAuth();

        var word = WordSummaryResponse.builder()
                .id(1L)
                .kanji("食べる")
                .hiragana("たべる")
                .definitionZh("吃、食用")
                .definitionEn("to eat")
                .partOfSpeech("verb")
                .jlptLevel("N5")
                .build();

        var page = new PageImpl<>(List.of(word), PageRequest.of(0, 20), 1);
        when(vocabularyService.searchWords(eq("N5"), isNull(), isNull(), isNull(), any()))
                .thenReturn(page);

        mockMvc.perform(get("/api/vocabulary")
                        .param("jlptLevel", "N5")
                        .header("Authorization", "Bearer valid-jwt"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].kanji").value("食べる"))
                .andExpect(jsonPath("$.content[0].hiragana").value("たべる"))
                .andExpect(jsonPath("$.content[0].jlptLevel").value("N5"))
                .andExpect(jsonPath("$.totalElements").value(1));
    }

    @Test
    @DisplayName("GET /api/vocabulary/{id} 應回傳單字詳情含例句")
    void getWordDetail_success() throws Exception {
        setupAuth();

        var detail = WordDetailResponse.builder()
                .id(1L)
                .kanji("食べる")
                .hiragana("たべる")
                .definitionZh("吃、食用")
                .definitionEn("to eat")
                .partOfSpeech("verb")
                .verbType("ichidan")
                .jlptLevel("N5")
                .examples(List.of(
                        ExampleResponse.builder()
                                .id(1L)
                                .sentenceJp("朝ごはんを食べる。")
                                .sentenceZh("吃早餐。")
                                .sentenceEn("I eat breakfast.")
                                .build()
                ))
                .relations(List.of())
                .build();

        when(vocabularyService.getWordDetail(1L)).thenReturn(detail);

        mockMvc.perform(get("/api/vocabulary/1")
                        .header("Authorization", "Bearer valid-jwt"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.kanji").value("食べる"))
                .andExpect(jsonPath("$.examples[0].sentenceJp").value("朝ごはんを食べる。"))
                .andExpect(jsonPath("$.verbType").value("ichidan"));
    }

    @Test
    @DisplayName("GET /api/vocabulary/categories 應回傳分類樹")
    void getCategories_success() throws Exception {
        setupAuth();

        var category = CategoryResponse.builder()
                .id(1L)
                .nameJp("食べ物")
                .nameZh("食物")
                .nameEn("Food")
                .children(List.of(
                        CategoryResponse.builder()
                                .id(2L)
                                .nameJp("果物")
                                .nameZh("水果")
                                .nameEn("Fruits")
                                .children(List.of())
                                .build()
                ))
                .build();

        when(vocabularyService.getCategoryTree()).thenReturn(List.of(category));

        mockMvc.perform(get("/api/vocabulary/categories")
                        .header("Authorization", "Bearer valid-jwt"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].nameEn").value("Food"))
                .andExpect(jsonPath("$[0].children[0].nameEn").value("Fruits"));
    }
}
