package com.jlpt_mono.app.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(name = "audio_cache", uniqueConstraints = {
        @UniqueConstraint(name = "uq_audio_cache_vocab_voice", columnNames = {"vocabulary_id", "voice_id"})
})
@Getter
@Setter
@NoArgsConstructor
public class AudioCache {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vocabulary_id", nullable = false)
    private Word word;

    @Column(name = "voice_id", nullable = false, length = 100)
    private String voiceId;

    @Column(name = "source_text", nullable = false, length = 255)
    private String sourceText;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private AudioCacheStatus status;

    @Column(name = "b2_object_key", length = 512)
    private String b2ObjectKey;

    @Column(name = "last_error", columnDefinition = "TEXT")
    private String lastError;

    @Column(name = "processing_started_at")
    private Instant processingStartedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
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
