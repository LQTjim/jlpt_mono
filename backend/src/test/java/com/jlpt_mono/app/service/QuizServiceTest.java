package com.jlpt_mono.app.service;

import com.jlpt_mono.app.dto.*;
import com.jlpt_mono.app.entity.*;
import com.jlpt_mono.app.exception.ResourceNotFoundException;
import com.jlpt_mono.app.repository.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class QuizServiceTest {

    @Mock
    private QuizSessionRepository quizSessionRepository;
    @Mock
    private QuizQuestionRepository quizQuestionRepository;
    @Mock
    private WordRepository wordRepository;
    @Mock
    private ExampleRepository exampleRepository;
    @Mock
    private UserRepository userRepository;

    private QuizService quizService;

    @BeforeEach
    void setUp() {
        quizService = new QuizService(
                quizSessionRepository, quizQuestionRepository,
                wordRepository, exampleRepository, userRepository);
    }

    private User createTestUser() {
        User user = new User();
        user.setId(1L);
        user.setEmail("test@example.com");
        return user;
    }

    private Word createTestWord(Long id, String kanji, String hiragana, String defZh) {
        Word word = new Word();
        word.setId(id);
        word.setKanji(kanji);
        word.setHiragana(hiragana);
        word.setDefinitionZh(defZh);
        word.setDefinitionEn("en-" + kanji);
        word.setJlptLevel("N5");
        word.setPartOfSpeech("verb");
        return word;
    }

    @Test
    @DisplayName("開始測驗：應建立 session 並回傳 10 題")
    void startQuiz_createsSessionAndQuestions() {
        User user = createTestUser();
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // Prepare 10 words for regular questions
        List<Word> words = List.of(
                createTestWord(1L, "食べる", "たべる", "吃"),
                createTestWord(2L, "飲む", "のむ", "喝"),
                createTestWord(3L, "走る", "はしる", "跑"),
                createTestWord(4L, "読む", "よむ", "讀"),
                createTestWord(5L, "書く", "かく", "寫"),
                createTestWord(6L, "見る", "みる", "看"),
                createTestWord(7L, "聞く", "きく", "聽"),
                createTestWord(8L, "話す", "はなす", "說"),
                createTestWord(9L, "歩く", "あるく", "走"),
                createTestWord(10L, "泳ぐ", "およぐ", "游泳")
        );
        when(wordRepository.findRandomByJlptLevel("N5", 10)).thenReturn(words);

        // Distractors for each question
        List<Word> distractors = List.of(
                createTestWord(11L, "寝る", "ねる", "睡覺"),
                createTestWord(12L, "起きる", "おきる", "起床"),
                createTestWord(13L, "遊ぶ", "あそぶ", "玩")
        );
        when(wordRepository.findRandomDistractors(eq("N5"), anyLong(), eq(3)))
                .thenReturn(distractors);

        when(quizSessionRepository.saveAndFlush(any(QuizSession.class)))
                .thenAnswer(invocation -> {
                    QuizSession s = invocation.getArgument(0);
                    if (s.getId() == null) s.setId(1L);
                    long qId = 100L;
                    for (QuizQuestion q : s.getQuestions()) {
                        if (q.getId() == null) q.setId(qId++);
                    }
                    return s;
                });

        QuizStartRequest request = new QuizStartRequest();
        request.setJlptLevel("N5");
        request.setQuestionType("MEANING");
        request.setLocale("zh");

        QuizStartResponse response = quizService.startQuiz(1L, request);

        assertThat(response.getSessionId()).isEqualTo(1L);
        assertThat(response.getQuestions()).hasSize(10);
        assertThat(response.getQuestions().getFirst().getType()).isEqualTo("MEANING");
        assertThat(response.getQuestions().getFirst().getOptions()).hasSize(4);

        // Verify each question has exactly one correct key among A-D
        for (var q : response.getQuestions()) {
            assertThat(q.getOptions()).extracting(o -> o.get("key"))
                    .containsExactlyInAnyOrder("A", "B", "C", "D");
        }
    }

    @Test
    @DisplayName("開始測驗：使用者不存在時應拋出 ResourceNotFoundException")
    void startQuiz_userNotFound() {
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        QuizStartRequest request = new QuizStartRequest();
        request.setJlptLevel("N5");
        request.setQuestionType("MEANING");
        request.setLocale("zh");

        assertThatThrownBy(() -> quizService.startQuiz(999L, request))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessageContaining("User not found");
    }

    @Test
    @DisplayName("提交答案：應計算分數並回傳結果")
    void submitQuiz_calculatesScore() {
        User user = createTestUser();
        QuizSession session = new QuizSession();
        session.setId(1L);
        session.setUser(user);
        session.setTotal(3);

        when(quizSessionRepository.findById(1L)).thenReturn(Optional.of(session));

        // 3 questions with correct keys
        QuizQuestion q1 = new QuizQuestion();
        q1.setId(10L);
        q1.setSession(session);
        q1.setSeq(1);
        q1.setCorrectKey("A");
        QuizQuestion q2 = new QuizQuestion();
        q2.setId(11L);
        q2.setSession(session);
        q2.setSeq(2);
        q2.setCorrectKey("B");
        QuizQuestion q3 = new QuizQuestion();
        q3.setId(12L);
        q3.setSession(session);
        q3.setSeq(3);
        q3.setCorrectKey("C");

        when(quizQuestionRepository.findBySessionIdOrderBySeqAsc(1L))
                .thenReturn(List.of(q1, q2, q3));
        when(quizSessionRepository.save(any())).thenAnswer(i -> i.getArgument(0));

        QuizSubmitRequest request = new QuizSubmitRequest();
        var a1 = new QuizSubmitRequest.AnswerItem();
        a1.setQuestionId(10L);
        a1.setSelectedKey("A"); // correct
        var a2 = new QuizSubmitRequest.AnswerItem();
        a2.setQuestionId(11L);
        a2.setSelectedKey("A"); // wrong
        var a3 = new QuizSubmitRequest.AnswerItem();
        a3.setQuestionId(12L);
        a3.setSelectedKey(null); // skipped
        request.setAnswers(List.of(a1, a2, a3));

        QuizSubmitResponse response = quizService.submitQuiz(1L, 1L, request);

        assertThat(response.getScore()).isEqualTo(1);
        assertThat(response.getTotal()).isEqualTo(3);
        assertThat(response.getResults()).hasSize(3);
        assertThat(response.getResults().get(0).isCorrect()).isTrue();
        assertThat(response.getResults().get(1).isCorrect()).isFalse();
        assertThat(response.getResults().get(2).isCorrect()).isFalse();
        assertThat(response.getResults().get(2).getSelectedKey()).isNull();

        // Verify session marked as completed
        ArgumentCaptor<QuizSession> captor = ArgumentCaptor.forClass(QuizSession.class);
        verify(quizSessionRepository).save(captor.capture());
        assertThat(captor.getValue().getCompletedAt()).isNotNull();
        assertThat(captor.getValue().getScore()).isEqualTo(1);
    }

    @Test
    @DisplayName("提交答案：不同使用者的 session 應拋出 ResourceNotFoundException")
    void submitQuiz_wrongUser() {
        User user = createTestUser();
        QuizSession session = new QuizSession();
        session.setId(1L);
        session.setUser(user);

        when(quizSessionRepository.findById(1L)).thenReturn(Optional.of(session));

        QuizSubmitRequest request = new QuizSubmitRequest();
        request.setAnswers(List.of());

        assertThatThrownBy(() -> quizService.submitQuiz(999L, 1L, request))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("提交答案：已完成的 session 應拋出 IllegalStateException")
    void submitQuiz_alreadyCompleted() {
        User user = createTestUser();
        QuizSession session = new QuizSession();
        session.setId(1L);
        session.setUser(user);
        session.setCompletedAt(Instant.now());

        when(quizSessionRepository.findById(1L)).thenReturn(Optional.of(session));

        QuizSubmitRequest request = new QuizSubmitRequest();
        request.setAnswers(List.of());

        assertThatThrownBy(() -> quizService.submitQuiz(1L, 1L, request))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("already completed");
    }

    @Test
    @DisplayName("查詢歷史：應回傳已完成的測驗分頁列表")
    void getHistory_returnsCompletedSessions() {
        QuizSession session = new QuizSession();
        session.setId(1L);
        session.setJlptLevel("N5");
        session.setScore(8);
        session.setTotal(10);
        session.setCompletedAt(Instant.now());

        var pageable = PageRequest.of(0, 10);
        var page = new PageImpl<>(List.of(session), pageable, 1);
        when(quizSessionRepository.findByUserIdAndCompletedAtIsNotNullOrderByCompletedAtDesc(1L, pageable))
                .thenReturn(page);

        var result = quizService.getHistory(1L, pageable);

        assertThat(result.getTotalElements()).isEqualTo(1);
        assertThat(result.getContent().getFirst().getScore()).isEqualTo(8);
        assertThat(result.getContent().getFirst().getJlptLevel()).isEqualTo("N5");
    }

    @Test
    @DisplayName("開始測驗：SENTENCE_FILL 應使用有例句的單字")
    void startQuiz_sentenceFill() {
        User user = createTestUser();
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        List<Word> sentenceWords = List.of(
                createTestWord(1L, "食べる", "たべる", "吃"),
                createTestWord(2L, "飲む", "のむ", "喝"),
                createTestWord(3L, "走る", "はしる", "跑"),
                createTestWord(4L, "読む", "よむ", "讀"),
                createTestWord(5L, "書く", "かく", "寫"),
                createTestWord(6L, "見る", "みる", "看"),
                createTestWord(7L, "聞く", "きく", "聽"),
                createTestWord(8L, "話す", "はなす", "說"),
                createTestWord(9L, "歩く", "あるく", "走"),
                createTestWord(10L, "泳ぐ", "およぐ", "游泳")
        );

        when(wordRepository.findRandomWithExamplesByJlptLevel("N5", 10)).thenReturn(sentenceWords);

        Example example = new Example();
        example.setId(1L);
        example.setSentenceJp("毎日話す。");
        example.setSentenceZh("每天說話。");
        when(exampleRepository.findByWordId(anyLong())).thenReturn(List.of(example));

        when(wordRepository.findRandomDistractors(eq("N5"), anyLong(), eq(3)))
                .thenReturn(List.of(
                        createTestWord(11L, "寝る", "ねる", "睡覺"),
                        createTestWord(12L, "起きる", "おきる", "起床"),
                        createTestWord(13L, "遊ぶ", "あそぶ", "玩")
                ));

        when(quizSessionRepository.saveAndFlush(any(QuizSession.class)))
                .thenAnswer(invocation -> {
                    QuizSession s = invocation.getArgument(0);
                    if (s.getId() == null) s.setId(1L);
                    long qId = 100L;
                    for (QuizQuestion q : s.getQuestions()) {
                        if (q.getId() == null) q.setId(qId++);
                    }
                    return s;
                });

        QuizStartRequest request = new QuizStartRequest();
        request.setJlptLevel("N5");
        request.setQuestionType("SENTENCE_FILL");
        request.setLocale("zh");

        QuizStartResponse response = quizService.startQuiz(1L, request);

        assertThat(response.getQuestions()).hasSize(10);
        // All questions should be SENTENCE_FILL
        assertThat(response.getQuestions()).allMatch(q -> "SENTENCE_FILL".equals(q.getType()));
    }

    @Test
    @DisplayName("提交答案：重複的 questionId 只計算一次")
    void submitQuiz_duplicateQuestionIds() {
        User user = createTestUser();
        QuizSession session = new QuizSession();
        session.setId(1L);
        session.setUser(user);
        session.setTotal(2);

        when(quizSessionRepository.findById(1L)).thenReturn(Optional.of(session));

        QuizQuestion q1 = new QuizQuestion();
        q1.setId(10L);
        q1.setSession(session);
        q1.setSeq(1);
        q1.setCorrectKey("A");

        when(quizQuestionRepository.findBySessionIdOrderBySeqAsc(1L))
                .thenReturn(List.of(q1));
        when(quizSessionRepository.save(any())).thenAnswer(i -> i.getArgument(0));

        // Send same questionId twice with correct answer
        QuizSubmitRequest request = new QuizSubmitRequest();
        var a1 = new QuizSubmitRequest.AnswerItem();
        a1.setQuestionId(10L);
        a1.setSelectedKey("A");
        var a2 = new QuizSubmitRequest.AnswerItem();
        a2.setQuestionId(10L);
        a2.setSelectedKey("A");
        request.setAnswers(List.of(a1, a2));

        QuizSubmitResponse response = quizService.submitQuiz(1L, 1L, request);

        // Score should be 1 not 2
        assertThat(response.getScore()).isEqualTo(1);
        assertThat(response.getResults()).hasSize(1);
    }
}
