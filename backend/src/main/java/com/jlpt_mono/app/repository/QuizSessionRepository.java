package com.jlpt_mono.app.repository;

import com.jlpt_mono.app.entity.QuizSession;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface QuizSessionRepository extends JpaRepository<QuizSession, Long> {

    Page<QuizSession> findByUserIdAndCompletedAtIsNotNullOrderByCompletedAtDesc(Long userId, Pageable pageable);

    long countByUserIdAndCompletedAtIsNotNull(Long userId);

    @Query("SELECT COALESCE(AVG(CASE WHEN qs.total > 0 THEN qs.score * 100.0 / qs.total ELSE 0 END), 0) FROM QuizSession qs WHERE qs.user.id = :userId AND qs.completedAt IS NOT NULL")
    double findAverageScorePercentageByUserId(@Param("userId") Long userId);

    @Query(value = """
            WITH RECURSIVE streak(d, cnt) AS (
              SELECT d, 1 FROM (
                SELECT DISTINCT DATE(completed_at AT TIME ZONE 'UTC') AS d
                FROM quiz_sessions
                WHERE user_id = :userId AND completed_at IS NOT NULL
                  AND DATE(completed_at AT TIME ZONE 'UTC') >= (NOW() AT TIME ZONE 'UTC')::date - 1
                ORDER BY d DESC
                LIMIT 1
              ) base
              UNION ALL
              SELECT s.d - 1, s.cnt + 1
              FROM streak s
              WHERE EXISTS (
                SELECT 1 FROM quiz_sessions
                WHERE user_id = :userId AND completed_at IS NOT NULL
                  AND DATE(completed_at AT TIME ZONE 'UTC') = s.d - 1
              )
            )
            SELECT COALESCE(MAX(cnt), 0) FROM streak
            """, nativeQuery = true)
    int findCurrentStreakByUserId(@Param("userId") Long userId);
}
