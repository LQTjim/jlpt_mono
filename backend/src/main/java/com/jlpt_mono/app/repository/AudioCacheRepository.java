package com.jlpt_mono.app.repository;

import com.jlpt_mono.app.entity.AudioCache;
import com.jlpt_mono.app.entity.AudioCacheStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.Optional;

public interface AudioCacheRepository extends JpaRepository<AudioCache, Long> {

    Optional<AudioCache> findByWordIdAndVoiceId(Long wordId, String voiceId);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("UPDATE AudioCache a SET a.status = com.jlpt_mono.app.entity.AudioCacheStatus.PROCESSING, a.processingStartedAt = :now, a.updatedAt = :now WHERE a.id = :id")
    void markProcessing(@Param("id") Long id, @Param("now") Instant now);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("UPDATE AudioCache a SET a.status = com.jlpt_mono.app.entity.AudioCacheStatus.READY, a.b2ObjectKey = :key, a.lastError = null, a.updatedAt = :now WHERE a.id = :id")
    void markReady(@Param("id") Long id, @Param("key") String key, @Param("now") Instant now);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("UPDATE AudioCache a SET a.status = com.jlpt_mono.app.entity.AudioCacheStatus.PENDING, a.lastError = null, a.updatedAt = :now WHERE a.id = :id")
    void markPending(@Param("id") Long id, @Param("now") Instant now);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("UPDATE AudioCache a SET a.status = com.jlpt_mono.app.entity.AudioCacheStatus.FAILED, a.lastError = :error, a.updatedAt = :now WHERE a.id = :id")
    void markFailed(@Param("id") Long id, @Param("error") String error, @Param("now") Instant now);

    /**
     * Conditional markFailed: only applies when the cache is still PROCESSING.
     * Prevents a dead-letter worker from overwriting a cache that was already re-queued
     * by a concurrent POST /generate after the task left the active set.
     */
    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("UPDATE AudioCache a SET a.status = com.jlpt_mono.app.entity.AudioCacheStatus.FAILED, a.lastError = :error, a.updatedAt = :now WHERE a.id = :id AND a.status = com.jlpt_mono.app.entity.AudioCacheStatus.PROCESSING")
    int markFailedIfProcessing(@Param("id") Long id, @Param("error") String error, @Param("now") Instant now);
}
