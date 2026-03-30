package com.jlpt_mono.app.service;

import com.jlpt_mono.app.dto.*;
import com.jlpt_mono.app.entity.*;
import com.jlpt_mono.app.exception.ResourceNotFoundException;
import com.jlpt_mono.app.repository.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;

@Service
@Transactional(readOnly = true)
public class QuizService {

    private static final int QUESTION_COUNT = 10;
    private static final int OPTIONS_COUNT = 4;
    private static final String[] KEYS = {"A", "B", "C", "D"};
    private static final String BLANK = "＿＿＿";

    private final QuizSessionRepository quizSessionRepository;
    private final QuizQuestionRepository quizQuestionRepository;
    private final WordRepository wordRepository;
    private final ExampleRepository exampleRepository;
    private final UserRepository userRepository;
    private final Random random = new Random();

    public QuizService(QuizSessionRepository quizSessionRepository,
                       QuizQuestionRepository quizQuestionRepository,
                       WordRepository wordRepository,
                       ExampleRepository exampleRepository,
                       UserRepository userRepository) {
        this.quizSessionRepository = quizSessionRepository;
        this.quizQuestionRepository = quizQuestionRepository;
        this.wordRepository = wordRepository;
        this.exampleRepository = exampleRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public QuizStartResponse startQuiz(Long userId, QuizStartRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        String jlptLevel = request.getJlptLevel().trim();
        String questionType = request.getQuestionType().trim();
        String locale = request.getLocale().trim();
        boolean isZh = "zh".equals(locale);

        // Fetch words
        List<Word> words;
        if ("SENTENCE_FILL".equals(questionType)) {
            words = wordRepository.findRandomWithExamplesByJlptLevel(jlptLevel, QUESTION_COUNT);
        } else {
            words = wordRepository.findRandomByJlptLevel(jlptLevel, QUESTION_COUNT);
        }

        // Create session (don't save yet — save once with all questions for reliable cascade)
        QuizSession session = new QuizSession();
        session.setUser(user);
        session.setJlptLevel(jlptLevel);
        session.setTotal(QUESTION_COUNT);

        // Build questions
        List<WordWithExample> builtQuestions = new ArrayList<>();
        // DB round trip 多次, 若要改善需要拉多題一次查
        for (int seq = 1; seq <= words.size(); seq++) {
            Word targetWord = words.get(seq - 1);
            Example example = null;

            if ("SENTENCE_FILL".equals(questionType)) {
                List<Example> examples = exampleRepository.findByWordId(targetWord.getId());
                if (!examples.isEmpty()) {
                    example = examples.get(random.nextInt(examples.size()));
                }
            }
            QuizQuestion question = buildQuestion(session, seq, questionType, targetWord, example, jlptLevel, isZh);
            session.getQuestions().add(question);
            builtQuestions.add(new WordWithExample(question, targetWord, example));
        }

        // Single saveAndFlush: persist session + cascade-persist all questions + assign IDs
        quizSessionRepository.saveAndFlush(session);

        List<QuizStartResponse.QuestionItem> questionItems = builtQuestions.stream()
                .map(we -> toQuestionItem(we.question, we.word, we.example, isZh))
                .toList();

        return QuizStartResponse.builder()
                .sessionId(session.getId())
                .questions(questionItems)
                .build();
    }

    @Transactional
    public QuizSubmitResponse submitQuiz(Long userId, Long sessionId, QuizSubmitRequest request) {
        QuizSession session = quizSessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Quiz session not found: " + sessionId));

        if (!session.getUser().getId().equals(userId)) {
            throw new ResourceNotFoundException("Quiz session not found: " + sessionId);
        }
        if (session.getCompletedAt() != null) {
            throw new IllegalStateException("Quiz session already completed");
        }

        List<QuizQuestion> questions = quizQuestionRepository.findBySessionIdOrderBySeqAsc(sessionId);
        Map<Long, QuizQuestion> questionMap = new LinkedHashMap<>();
        for (QuizQuestion q : questions) {
            questionMap.put(q.getId(), q);
        }

        int score = 0;
        List<QuizSubmitResponse.ResultItem> results = new ArrayList<>();
        Set<Long> processedIds = new HashSet<>();

        for (QuizSubmitRequest.AnswerItem answerItem : request.getAnswers()) {
            QuizQuestion question = questionMap.get(answerItem.getQuestionId());
            if (question == null) continue;
            if (!processedIds.add(question.getId())) continue;

            boolean isCorrect = question.getCorrectKey().equals(answerItem.getSelectedKey());
            if (isCorrect) score++;

            QuizAnswer answer = new QuizAnswer();
            answer.setQuestion(question);
            answer.setSelectedKey(answerItem.getSelectedKey());
            answer.setCorrect(isCorrect);
            question.setAnswer(answer);

            results.add(QuizSubmitResponse.ResultItem.builder()
                    .questionId(question.getId())
                    .correct(isCorrect)
                    .correctKey(question.getCorrectKey())
                    .selectedKey(answerItem.getSelectedKey())
                    .build());
        }

        session.setScore(score);
        session.setCompletedAt(Instant.now());
        quizSessionRepository.save(session);

        return QuizSubmitResponse.builder()
                .sessionId(sessionId)
                .score(score)
                .total(session.getTotal())
                .results(results)
                .build();
    }

    public Page<QuizHistoryResponse> getHistory(Long userId, Pageable pageable) {
        return quizSessionRepository
                .findByUserIdAndCompletedAtIsNotNullOrderByCompletedAtDesc(userId, pageable)
                .map(QuizHistoryResponse::from);
    }

    // --- Question builders ---

    private QuizQuestion buildQuestion(QuizSession session, int seq, String type,
                                        Word targetWord, Example example, String jlptLevel, boolean isZh) {
        List<Word> distractors = wordRepository.findRandomDistractors(jlptLevel, targetWord.getId(), OPTIONS_COUNT - 1);

        // Build options list: correct + distractors, then shuffle
        List<OptionEntry> entries = new ArrayList<>();
        entries.add(new OptionEntry(optionText(type, targetWord, isZh), true));
        for (Word d : distractors) {
            entries.add(new OptionEntry(optionText(type, d, isZh), false));
        }
        Collections.shuffle(entries, random);

        // Assign keys A-D and find correct key
        String correctKey = null;
        List<Map<String, String>> options = new ArrayList<>();
        for (int i = 0; i < entries.size(); i++) {
            String key = KEYS[i];
            options.add(Map.of("key", key, "text", entries.get(i).text));
            if (entries.get(i).correct) {
                correctKey = key;
            }
        }

        QuizQuestion question = new QuizQuestion();
        question.setSession(session);
        question.setSeq(seq);
        question.setType(type);
        question.setWord(targetWord);
        question.setExample(example);
        question.setCorrectKey(correctKey);
        question.setOptions(options);
        return question;
    }

    private String optionText(String type, Word word, boolean isZh) {
        return switch (type) {
            case "MEANING" -> {
                // Options show definitions — user picks the meaning of the word
                String zh = word.getDefinitionZh();
                String en = word.getDefinitionEn();
                if (isZh) {
                    yield (zh != null && !zh.isBlank()) ? zh : (en != null ? en : "");
                } else {
                    yield (en != null && !en.isBlank()) ? en : (zh != null ? zh : "");
                }
            }
            case "REVERSE" -> {
                // Options show Japanese words — user picks the word matching the definition
                String display = word.getKanji() != null && !word.getKanji().isBlank()
                        ? word.getKanji() : word.getHiragana();
                if (word.getHiragana() != null && word.getKanji() != null && !word.getKanji().isBlank()) {
                    display += " (" + word.getHiragana() + ")";
                }
                yield display;
            }
            case "SENTENCE_FILL" -> {
                // Options show Japanese words — user picks the word that fills the blank
                yield word.getKanji() != null && !word.getKanji().isBlank()
                        ? word.getKanji() : word.getHiragana();
            }
            default -> "";
        };
    }

    private QuizStartResponse.QuestionItem toQuestionItem(QuizQuestion question, Word word, Example example, boolean isZh) {
        QuizStartResponse.StemItem stem;

        switch (question.getType()) {
            case "MEANING" -> stem = QuizStartResponse.StemItem.builder()
                    .kanji(word.getKanji())
                    .hiragana(word.getHiragana())
                    .build();
            case "REVERSE" -> {
                String definition = isZh
                        ? firstNonBlank(word.getDefinitionZh(), word.getDefinitionEn())
                        : firstNonBlank(word.getDefinitionEn(), word.getDefinitionZh());
                stem = QuizStartResponse.StemItem.builder()
                        .definitionZh(isZh ? definition : null)
                        .definitionEn(isZh ? null : definition)
                        .build();
            }
            case "SENTENCE_FILL" -> {
                String sentenceJp = "";
                String translation = "";
                if (example != null) {
                    sentenceJp = blankOutWord(example.getSentenceJp(), word);
                    translation = isZh
                            ? firstNonBlank(example.getSentenceZh(), example.getSentenceEn())
                            : firstNonBlank(example.getSentenceEn(), example.getSentenceZh());
                }
                stem = QuizStartResponse.StemItem.builder()
                        .sentence(sentenceJp)
                        .translation(translation)
                        .build();
            }
            default -> stem = QuizStartResponse.StemItem.builder().build();
        }

        return QuizStartResponse.QuestionItem.builder()
                .id(question.getId())
                .type(question.getType())
                .stem(stem)
                .options(question.getOptions())
                .build();
    }

    /**
     * Replace the target word (including conjugated forms) in a sentence with ＿＿＿.
     * Tries: exact kanji → exact hiragana → kanji stem → hiragana stem.
     */
    String blankOutWord(String sentence, Word word) {
        String kanji = word.getKanji();
        String hiragana = word.getHiragana();

        // Try exact kanji match
        if (kanji != null && !kanji.isBlank() && sentence.contains(kanji)) {
            return sentence.replace(kanji, BLANK);
        }
        // Try exact hiragana match
        if (hiragana != null && sentence.contains(hiragana)) {
            return sentence.replace(hiragana, BLANK);
        }
        // Try kanji stem match (e.g., 食べる → 食べ matches 食べます)
        if (kanji != null && kanji.length() > 1) {
            String kanjiStem = kanji.substring(0, kanji.length() - 1);
            int idx = sentence.indexOf(kanjiStem);
            if (idx >= 0) {
                // Find the end of the conjugated form (consume trailing hiragana)
                int end = idx + kanjiStem.length();
                while (end < sentence.length() && isHiragana(sentence.charAt(end))) {
                    end++;
                }
                return sentence.substring(0, idx) + BLANK + sentence.substring(end);
            }
        }
        // Try hiragana stem match
        if (hiragana != null && hiragana.length() > 1) {
            String hiraganaStem = hiragana.substring(0, hiragana.length() - 1);
            int idx = sentence.indexOf(hiraganaStem);
            if (idx >= 0) {
                int end = idx + hiraganaStem.length();
                while (end < sentence.length() && isHiragana(sentence.charAt(end))) {
                    end++;
                }
                return sentence.substring(0, idx) + BLANK + sentence.substring(end);
            }
        }
        // Fallback: return original sentence (question still usable, just less ideal)
        return sentence;
    }

    private static boolean isHiragana(char c) {
        return c >= '\u3040' && c <= '\u309F';
    }

    private static String firstNonBlank(String preferred, String fallback) {
        if (preferred != null && !preferred.isBlank()) return preferred;
        if (fallback != null && !fallback.isBlank()) return fallback;
        return "";
    }

    private record OptionEntry(String text, boolean correct) {}

    private record WordWithExample(QuizQuestion question, Word word, Example example) {}
}
