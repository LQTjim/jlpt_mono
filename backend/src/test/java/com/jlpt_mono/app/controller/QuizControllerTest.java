package com.jlpt_mono.app.controller;

import com.jlpt_mono.app.config.SecurityConfig;
import com.jlpt_mono.app.dto.*;
import com.jlpt_mono.app.security.JwtAuthenticationFilter;
import com.jlpt_mono.app.security.JwtTokenProvider;
import com.jlpt_mono.app.service.QuizService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.util.List;
import java.util.Map;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(QuizController.class)
@Import({SecurityConfig.class, JwtAuthenticationFilter.class})
class QuizControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private QuizService quizService;

    @MockitoBean
    private JwtTokenProvider jwtTokenProvider;

    private void setupAuth() {
        when(jwtTokenProvider.validateToken("valid-jwt")).thenReturn(true);
        when(jwtTokenProvider.getUserIdFromToken("valid-jwt")).thenReturn(1L);
    }

    @Test
    @DisplayName("POST /api/quiz/start 無認證時應回傳 401")
    void startQuiz_unauthenticated() throws Exception {
        mockMvc.perform(post("/api/quiz/start")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"jlptLevel\":\"N5\",\"questionType\":\"MEANING\",\"locale\":\"zh\"}"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("POST /api/quiz/start 應回傳 session 和題目")
    void startQuiz_success() throws Exception {
        setupAuth();

        var response = QuizStartResponse.builder()
                .sessionId(1L)
                .questions(List.of(
                        QuizStartResponse.QuestionItem.builder()
                                .id(10L)
                                .type("MEANING")
                                .stem(QuizStartResponse.StemItem.builder()
                                        .kanji("食べる")
                                        .hiragana("たべる")
                                        .build())
                                .options(List.of(
                                        Map.of("key", "A", "text", "吃"),
                                        Map.of("key", "B", "text", "喝"),
                                        Map.of("key", "C", "text", "玩"),
                                        Map.of("key", "D", "text", "跑")
                                ))
                                .build()
                ))
                .build();

        when(quizService.startQuiz(eq(1L), any(QuizStartRequest.class))).thenReturn(response);

        mockMvc.perform(post("/api/quiz/start")
                        .header("Authorization", "Bearer valid-jwt")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"jlptLevel\":\"N5\",\"questionType\":\"MEANING\",\"locale\":\"zh\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.sessionId").value(1))
                .andExpect(jsonPath("$.questions[0].type").value("MEANING"))
                .andExpect(jsonPath("$.questions[0].stem.kanji").value("食べる"))
                .andExpect(jsonPath("$.questions[0].options").isArray())
                .andExpect(jsonPath("$.questions[0].options[0].key").value("A"));
    }

    @Test
    @DisplayName("POST /api/quiz/{id}/submit 應回傳分數和結果")
    void submitQuiz_success() throws Exception {
        setupAuth();

        var response = QuizSubmitResponse.builder()
                .sessionId(1L)
                .score(8)
                .total(10)
                .results(List.of(
                        QuizSubmitResponse.ResultItem.builder()
                                .questionId(10L)
                                .correct(true)
                                .correctKey("A")
                                .selectedKey("A")
                                .build(),
                        QuizSubmitResponse.ResultItem.builder()
                                .questionId(11L)
                                .correct(false)
                                .correctKey("B")
                                .selectedKey("C")
                                .build()
                ))
                .build();

        when(quizService.submitQuiz(eq(1L), eq(1L), any(QuizSubmitRequest.class))).thenReturn(response);

        String body = """
                {"answers":[
                    {"questionId":10,"selectedKey":"A"},
                    {"questionId":11,"selectedKey":"C"}
                ]}""";

        mockMvc.perform(post("/api/quiz/1/submit")
                        .header("Authorization", "Bearer valid-jwt")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.score").value(8))
                .andExpect(jsonPath("$.total").value(10))
                .andExpect(jsonPath("$.results[0].correct").value(true))
                .andExpect(jsonPath("$.results[1].correct").value(false));
    }

    @Test
    @DisplayName("GET /api/quiz/history 應回傳分頁成績列表")
    void getHistory_success() throws Exception {
        setupAuth();

        var history = QuizHistoryResponse.builder()
                .sessionId(1L)
                .jlptLevel("N5")
                .score(8)
                .total(10)
                .completedAt(Instant.parse("2026-03-26T10:30:00Z"))
                .build();

        var page = new PageImpl<>(List.of(history), PageRequest.of(0, 10), 1);
        when(quizService.getHistory(eq(1L), any())).thenReturn(page);

        mockMvc.perform(get("/api/quiz/history")
                        .header("Authorization", "Bearer valid-jwt"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].sessionId").value(1))
                .andExpect(jsonPath("$.content[0].jlptLevel").value("N5"))
                .andExpect(jsonPath("$.content[0].score").value(8))
                .andExpect(jsonPath("$.totalElements").value(1));
    }

    @Test
    @DisplayName("GET /api/quiz/history 無認證時應回傳 401")
    void getHistory_unauthenticated() throws Exception {
        mockMvc.perform(get("/api/quiz/history"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("POST /api/quiz/start 無效 jlptLevel 應回傳 400")
    void startQuiz_invalidJlptLevel() throws Exception {
        setupAuth();
        mockMvc.perform(post("/api/quiz/start")
                        .header("Authorization", "Bearer valid-jwt")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"jlptLevel\":\"N9\",\"questionType\":\"MEANING\",\"locale\":\"zh\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("bad_request"));
    }

    @Test
    @DisplayName("POST /api/quiz/start 無效 questionType 應回傳 400")
    void startQuiz_invalidQuestionType() throws Exception {
        setupAuth();
        mockMvc.perform(post("/api/quiz/start")
                        .header("Authorization", "Bearer valid-jwt")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"jlptLevel\":\"N5\",\"questionType\":\"FOO\",\"locale\":\"zh\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("bad_request"));
    }

    @Test
    @DisplayName("POST /api/quiz/start 缺少 questionType 應回傳 400")
    void startQuiz_missingQuestionType() throws Exception {
        setupAuth();
        mockMvc.perform(post("/api/quiz/start")
                        .header("Authorization", "Bearer valid-jwt")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"jlptLevel\":\"N5\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("bad_request"));
    }

    @Test
    @DisplayName("POST /api/quiz/{id}/submit 無效 selectedKey 應回傳 400")
    void submitQuiz_invalidSelectedKey() throws Exception {
        setupAuth();
        mockMvc.perform(post("/api/quiz/1/submit")
                        .header("Authorization", "Bearer valid-jwt")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"answers\":[{\"questionId\":10,\"selectedKey\":\"Z\"}]}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("bad_request"));
    }
}
