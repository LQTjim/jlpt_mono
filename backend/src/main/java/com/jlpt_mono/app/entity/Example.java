package com.jlpt_mono.app.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(name = "examples")
@Getter
@Setter
@NoArgsConstructor
public class Example {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "word_id", nullable = false)
    private Word word;

    @Column(name = "sentence_jp", nullable = false, columnDefinition = "TEXT")
    private String sentenceJp;

    @Column(name = "sentence_zh", columnDefinition = "TEXT")
    private String sentenceZh;

    @Column(name = "sentence_en", columnDefinition = "TEXT")
    private String sentenceEn;

    @Column(name = "created_at", updatable = false)
    private Instant createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = Instant.now();
    }
}
