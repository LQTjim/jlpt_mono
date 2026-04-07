package com.jlpt_mono.app;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jlpt_mono.app.entity.User;
import com.jlpt_mono.app.repository.QuizQuestionRepository;
import com.jlpt_mono.app.repository.UserRepository;
import com.jlpt_mono.app.security.JwtTokenProvider;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@Import(TestcontainersConfiguration.class)
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class QuizIntegrationTest {

    @Autowired private MockMvc mockMvc;
    private final ObjectMapper objectMapper = new ObjectMapper();
    @Autowired private UserRepository userRepository;
    @Autowired private QuizQuestionRepository quizQuestionRepository;
    @Autowired private JwtTokenProvider jwtTokenProvider;
    @Autowired private JdbcTemplate jdbcTemplate;

    private User savedUser;
    private String authToken;

    @BeforeEach
    void setUp() {
        User user = new User();
        user.setEmail(UUID.randomUUID() + "@quiz-test.com");
        user.setGoogleId("google-" + UUID.randomUUID());
        savedUser = userRepository.save(user);
        authToken = jwtTokenProvider.generateToken(savedUser);
    }

    @AfterEach
    void tearDown() {
        if (savedUser != null) {
            // quiz_questions / quiz_answers cascade via ON DELETE CASCADE from quiz_sessions
            jdbcTemplate.update("DELETE FROM quiz_sessions WHERE user_id = ?", savedUser.getId());
            userRepository.deleteById(savedUser.getId());
            savedUser = null;
        }
    }

    // --- Helpers ---

    @SuppressWarnings("unchecked")
    private Map<String, Object> startQuiz(String token, String type) throws Exception {
        String body = objectMapper.writeValueAsString(
                Map.of("jlptLevel", "N5", "questionType", type, "locale", "zh"));
        MvcResult result = mockMvc.perform(post("/api/quiz/start")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andReturn();
        return objectMapper.readValue(result.getResponse().getContentAsString(), Map.class);
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> submitAllCorrect(String token, Long sessionId) throws Exception {
        var answers = quizQuestionRepository.findBySessionIdOrderBySeqAsc(sessionId).stream()
                .map(q -> Map.<String, Object>of("questionId", q.getId(), "selectedKey", q.getCorrectKey()))
                .toList();
        String body = objectMapper.writeValueAsString(Map.of("answers", answers));
        MvcResult result = mockMvc.perform(post("/api/quiz/" + sessionId + "/submit")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andReturn();
        return objectMapper.readValue(result.getResponse().getContentAsString(), Map.class);
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> submitAllWrong(Long sessionId) throws Exception {
        var answers = quizQuestionRepository.findBySessionIdOrderBySeqAsc(sessionId).stream()
                .map(q -> {
                    String wrong = switch (q.getCorrectKey()) {
                        case "A" -> "B"; case "B" -> "C"; case "C" -> "D"; default -> "A";
                    };
                    return Map.<String, Object>of("questionId", q.getId(), "selectedKey", wrong);
                })
                .toList();
        String body = objectMapper.writeValueAsString(Map.of("answers", answers));
        MvcResult result = mockMvc.perform(post("/api/quiz/" + sessionId + "/submit")
                        .header("Authorization", "Bearer " + authToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andReturn();
        return objectMapper.readValue(result.getResponse().getContentAsString(), Map.class);
    }

    // --- Tests ---

    @Test
    @DisplayName("startQuiz MEANING: 200 + sessionId + 10 題，每題 4 選項")
    @SuppressWarnings("unchecked")
    void startQuiz_meaning_returns10QuestionsWithOptions() throws Exception {
        Map<String, Object> body = startQuiz(authToken, "MEANING");

        assertThat(body.get("sessionId")).isNotNull();
        List<Map<String, Object>> questions = (List<Map<String, Object>>) body.get("questions");
        assertThat(questions).hasSize(10);
        for (var q : questions) {
            assertThat(q.get("id")).isNotNull();
            assertThat((List<?>) q.get("options")).hasSize(4);
        }
    }

    @Test
    @DisplayName("startQuiz SENTENCE_FILL: 200 + 10 題，SENTENCE_FILL 題型有 sentence")
    @SuppressWarnings("unchecked")
    void startQuiz_sentenceFill_stemHasSentence() throws Exception {
        Map<String, Object> body = startQuiz(authToken, "SENTENCE_FILL");

        List<Map<String, Object>> questions = (List<Map<String, Object>>) body.get("questions");
        assertThat(questions).hasSize(10);
        boolean anySentence = questions.stream()
                .filter(q -> "SENTENCE_FILL".equals(q.get("type")))
                .anyMatch(q -> {
                    var stem = (Map<String, Object>) q.get("stem");
                    return stem != null && stem.get("sentence") != null;
                });
        assertThat(anySentence).isTrue();
    }

    @Test
    @DisplayName("startQuiz 無 auth header: 401")
    void startQuiz_unauthenticated_returns401() throws Exception {
        String body = objectMapper.writeValueAsString(
                Map.of("jlptLevel", "N5", "questionType", "MEANING", "locale", "zh"));
        mockMvc.perform(post("/api/quiz/start")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("startQuiz 非法等級 N9: 400")
    void startQuiz_invalidLevel_returns400() throws Exception {
        String body = objectMapper.writeValueAsString(
                Map.of("jlptLevel", "N9", "questionType", "MEANING", "locale", "zh"));
        mockMvc.perform(post("/api/quiz/start")
                        .header("Authorization", "Bearer " + authToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("submitQuiz 全對: score == 10，total == 10")
    void submitQuiz_allCorrect_scoreEquals10() throws Exception {
        Long sessionId = ((Number) startQuiz(authToken, "MEANING").get("sessionId")).longValue();

        Map<String, Object> result = submitAllCorrect(authToken, sessionId);

        assertThat(((Number) result.get("score")).intValue()).isEqualTo(10);
        assertThat(((Number) result.get("total")).intValue()).isEqualTo(10);
    }

    @Test
    @DisplayName("submitQuiz 全錯: score == 0")
    void submitQuiz_allWrong_scoreEquals0() throws Exception {
        Long sessionId = ((Number) startQuiz(authToken, "MEANING").get("sessionId")).longValue();

        Map<String, Object> result = submitAllWrong(sessionId);

        assertThat(((Number) result.get("score")).intValue()).isEqualTo(0);
    }

    @Test
    @DisplayName("submitQuiz 已完成再提交: 409 Conflict")
    void submitQuiz_alreadyCompleted_returns409() throws Exception {
        Long sessionId = ((Number) startQuiz(authToken, "MEANING").get("sessionId")).longValue();
        submitAllCorrect(authToken, sessionId);

        // Second submit attempt
        var answers = quizQuestionRepository.findBySessionIdOrderBySeqAsc(sessionId).stream()
                .map(q -> Map.<String, Object>of("questionId", q.getId(), "selectedKey", "A"))
                .toList();
        mockMvc.perform(post("/api/quiz/" + sessionId + "/submit")
                        .header("Authorization", "Bearer " + authToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("answers", answers))))
                .andExpect(status().isConflict());
    }

    @Test
    @DisplayName("submitQuiz 用其他 user 的 token: 404")
    void submitQuiz_wrongUser_returns404() throws Exception {
        User user2 = new User();
        user2.setEmail(UUID.randomUUID() + "@quiz-test.com");
        user2.setGoogleId("google-" + UUID.randomUUID());
        user2 = userRepository.save(user2);
        String token2 = jwtTokenProvider.generateToken(user2);
        Long user2Id = user2.getId();

        try {
            Long sessionId = ((Number) startQuiz(authToken, "MEANING").get("sessionId")).longValue();

            var answers = quizQuestionRepository.findBySessionIdOrderBySeqAsc(sessionId).stream()
                    .map(q -> Map.<String, Object>of("questionId", q.getId(), "selectedKey", "A"))
                    .toList();
            mockMvc.perform(post("/api/quiz/" + sessionId + "/submit")
                            .header("Authorization", "Bearer " + token2)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(Map.of("answers", answers))))
                    .andExpect(status().isNotFound());
        } finally {
            userRepository.deleteById(user2Id);
        }
    }

    @Test
    @DisplayName("getHistory: 完成後出現在列表，sessionId、score、jlptLevel 正確")
    @SuppressWarnings("unchecked")
    void getHistory_afterCompletion_appearsInList() throws Exception {
        Long sessionId = ((Number) startQuiz(authToken, "MEANING").get("sessionId")).longValue();
        submitAllCorrect(authToken, sessionId);

        MvcResult result = mockMvc.perform(get("/api/quiz/history")
                        .header("Authorization", "Bearer " + authToken))
                .andExpect(status().isOk())
                .andReturn();

        Map<String, Object> body = objectMapper.readValue(result.getResponse().getContentAsString(), Map.class);
        List<Map<String, Object>> content = (List<Map<String, Object>>) body.get("content");
        assertThat(content).isNotEmpty();
        Map<String, Object> entry = content.get(0);
        assertThat(((Number) entry.get("sessionId")).longValue()).isEqualTo(sessionId);
        assertThat(((Number) entry.get("score")).intValue()).isEqualTo(10);
        assertThat(entry.get("jlptLevel")).isEqualTo("N5");
    }

    @Test
    @DisplayName("getHistory 無 auth header: 401")
    void getHistory_unauthenticated_returns401() throws Exception {
        mockMvc.perform(get("/api/quiz/history"))
                .andExpect(status().isUnauthorized());
    }
}
