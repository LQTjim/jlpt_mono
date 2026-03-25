package com.jlpt_mono.app.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "words")
@Getter
@Setter
@NoArgsConstructor
public class Word {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(length = 100)
    private String kanji;

    @Column(nullable = false, length = 100)
    private String hiragana;

    @Column(length = 100)
    private String romaji;

    @Column(name = "definition_zh", columnDefinition = "TEXT")
    private String definitionZh;

    @Column(name = "definition_en", columnDefinition = "TEXT")
    private String definitionEn;

    @Column(name = "part_of_speech", length = 50)
    private String partOfSpeech;

    @Column(name = "verb_type", length = 50)
    private String verbType;

    @Column(name = "jlpt_level", length = 2)
    private String jlptLevel;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private Category category;

    @Column(name = "difficulty_score")
    private Short difficultyScore;

    @Column(name = "frequency_rank")
    private Integer frequencyRank;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @OneToMany(mappedBy = "word", fetch = FetchType.LAZY)
    private List<Example> examples = new ArrayList<>();

    @OneToMany(mappedBy = "word", fetch = FetchType.LAZY)
    private List<WordRelation> relations = new ArrayList<>();

    @Column(name = "created_at", updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at")
    private Instant updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = Instant.now();
        updatedAt = Instant.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = Instant.now();
    }
}
