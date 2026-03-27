package com.jlpt_mono.app.repository;

import com.jlpt_mono.app.entity.QuizQuestion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface QuizQuestionRepository extends JpaRepository<QuizQuestion, Long> {

    List<QuizQuestion> findBySessionIdOrderBySeqAsc(Long sessionId);
}
