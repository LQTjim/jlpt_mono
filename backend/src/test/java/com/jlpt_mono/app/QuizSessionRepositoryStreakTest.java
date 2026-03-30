package com.jlpt_mono.app;

import com.jlpt_mono.app.entity.QuizSession;
import com.jlpt_mono.app.entity.User;
import com.jlpt_mono.app.repository.QuizSessionRepository;
import com.jlpt_mono.app.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.ZoneOffset;

import static org.assertj.core.api.Assertions.assertThat;

@Import(TestcontainersConfiguration.class)
@SpringBootTest
@ActiveProfiles("test")
@Transactional
class QuizSessionRepositoryStreakTest {

    @Autowired
    private QuizSessionRepository quizSessionRepository;

    @Autowired
    private UserRepository userRepository;

    private User user;

    @BeforeEach
    void setUp() {
        user = new User();
        user.setEmail("streak-test@example.com");
        user.setGoogleId("google-streak-test-id");
        userRepository.save(user);
    }

    @Test
    @DisplayName("streak：無紀錄 → 0")
    void streak_noHistory() {
        assertThat(quizSessionRepository.findCurrentStreakByUserId(user.getId())).isZero();
    }

    @Test
    @DisplayName("streak：只有今天 → 1")
    void streak_todayOnly() {
        complete(LocalDate.now(ZoneOffset.UTC));

        assertThat(quizSessionRepository.findCurrentStreakByUserId(user.getId())).isEqualTo(1);
    }

    @Test
    @DisplayName("streak：連續 3 天（含今天） → 3")
    void streak_threeConsecutiveDays() {
        LocalDate today = LocalDate.now(ZoneOffset.UTC);
        complete(today);
        complete(today.minusDays(1));
        complete(today.minusDays(2));

        assertThat(quizSessionRepository.findCurrentStreakByUserId(user.getId())).isEqualTo(3);
    }

    @Test
    @DisplayName("streak：今天沒做但昨天有連續 2 天 → 2")
    void streak_startFromYesterday() {
        LocalDate today = LocalDate.now(ZoneOffset.UTC);
        complete(today.minusDays(1));
        complete(today.minusDays(2));

        assertThat(quizSessionRepository.findCurrentStreakByUserId(user.getId())).isEqualTo(2);
    }

    @Test
    @DisplayName("streak：最近日期是 2 天前 → 0（斷了）")
    void streak_brokenTwoDaysAgo() {
        complete(LocalDate.now(ZoneOffset.UTC).minusDays(2));

        assertThat(quizSessionRepository.findCurrentStreakByUserId(user.getId())).isZero();
    }

    @Test
    @DisplayName("streak：中間有斷 → 只算連續段")
    void streak_gapInMiddle() {
        LocalDate today = LocalDate.now(ZoneOffset.UTC);
        complete(today);
        complete(today.minusDays(1));
        complete(today.minusDays(3)); // gap

        assertThat(quizSessionRepository.findCurrentStreakByUserId(user.getId())).isEqualTo(2);
    }

    @Test
    @DisplayName("streak：同一天多筆 → 仍算 1 天")
    void streak_multipleSameDayCountsOnce() {
        LocalDate today = LocalDate.now(ZoneOffset.UTC);
        complete(today);
        complete(today);
        complete(today.minusDays(1));

        assertThat(quizSessionRepository.findCurrentStreakByUserId(user.getId())).isEqualTo(2);
    }

    @Test
    @DisplayName("streak：連續 400 天 → 400")
    void streak_400ConsecutiveDays() {
        LocalDate today = LocalDate.now(ZoneOffset.UTC);
        for (int i = 0; i < 400; i++) {
            complete(today.minusDays(i));
        }

        assertThat(quizSessionRepository.findCurrentStreakByUserId(user.getId())).isEqualTo(400);
    }

    private void complete(LocalDate date) {
        QuizSession session = new QuizSession();
        session.setUser(user);
        session.setJlptLevel("N5");
        session.setScore(8);
        session.setTotal(10);
        session.setCompletedAt(date.atStartOfDay(ZoneOffset.UTC).toInstant());
        quizSessionRepository.save(session);
    }
}
