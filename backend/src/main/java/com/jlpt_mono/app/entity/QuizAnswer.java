package com.jlpt_mono.app.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(name = "quiz_answers")
@Getter
@Setter
@NoArgsConstructor
public class QuizAnswer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id", nullable = false)
    private QuizQuestion question;

    @Column(name = "selected_key", length = 1)
    private String selectedKey;

    @Column(nullable = false)
    private boolean correct;

    @Column(name = "answered_at", updatable = false)
    private Instant answeredAt;

    @PrePersist
    protected void onCreate() {
        answeredAt = Instant.now();
    }
}
