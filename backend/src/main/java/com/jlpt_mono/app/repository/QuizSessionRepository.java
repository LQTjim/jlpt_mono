package com.jlpt_mono.app.repository;

import com.jlpt_mono.app.entity.QuizSession;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface QuizSessionRepository extends JpaRepository<QuizSession, Long> {

    Page<QuizSession> findByUserIdAndCompletedAtIsNotNullOrderByCompletedAtDesc(Long userId, Pageable pageable);
}
