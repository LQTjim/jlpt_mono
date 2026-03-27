package com.jlpt_mono.app.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.List;
import java.util.Map;

@Entity
@Table(name = "quiz_questions")
@Getter
@Setter
@NoArgsConstructor
public class QuizQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false)
    private QuizSession session;

    @Column(nullable = false)
    private int seq;

    @Column(nullable = false, length = 20)
    private String type;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "word_id", nullable = false)
    private Word word;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "example_id")
    private Example example;

    @Column(name = "correct_key", nullable = false, length = 1)
    private String correctKey;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private List<Map<String, String>> options;

    @Column(name = "created_at", updatable = false)
    private Instant createdAt;

    @OneToOne(mappedBy = "question", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private QuizAnswer answer;

    @PrePersist
    protected void onCreate() {
        createdAt = Instant.now();
    }
}
