package com.jlpt_mono.app.repository;

import com.jlpt_mono.app.entity.AudioTask;
import com.jlpt_mono.app.entity.AudioTaskStatus;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AudioTaskRepository extends JpaRepository<AudioTask, Long> {

    Optional<AudioTask> findByAudioCacheIdAndStatusIn(Long audioCacheId, Collection<AudioTaskStatus> statuses);

    /**
     * Loads an AudioTask together with its AudioCache and Word in a single query,
     * so callers outside a transaction (e.g. AudioWorkerService) don't hit LazyInitializationException.
     */
    @Query("SELECT t FROM AudioTask t JOIN FETCH t.audioCache c JOIN FETCH c.word WHERE t.id = :id")
    Optional<AudioTask> findByIdWithCache(@Param("id") Long id);

    /**
     * Finds stale CLAIMED tasks with an eager fetch of audioCache and word,
     * so callers outside a transaction (e.g. AudioRecoveryService) can access
     * lazy associations without a LazyInitializationException.
     */
    @Query("""
            SELECT t FROM AudioTask t
            JOIN FETCH t.audioCache c JOIN FETCH c.word
            WHERE t.status = :status AND t.leaseExpiresAt < :cutoff
            ORDER BY t.leaseExpiresAt ASC
            """)
    List<AudioTask> findStaleWithCache(@Param("status") AudioTaskStatus status,
                                       @Param("cutoff") Instant cutoff,
                                       Pageable pageable);

    /**
     * Atomically claims up to batchSize QUEUED tasks using CTE + FOR UPDATE SKIP LOCKED.
     * INTERACTIVE tasks are prioritised over RECOVERY. Returns claimed task IDs.
     */
    @Modifying
    @Query(nativeQuery = true, value = """
            WITH candidates AS (
                SELECT id FROM audio_task
                WHERE status = 'QUEUED' AND available_at <= NOW()
                ORDER BY CASE priority WHEN 'INTERACTIVE' THEN 0 ELSE 1 END, available_at, created_at
                LIMIT :batchSize FOR UPDATE SKIP LOCKED
            )
            UPDATE audio_task
            SET status = 'CLAIMED',
                claimed_at = NOW(),
                lease_expires_at = NOW() + make_interval(secs => :leaseSecs),
                heartbeat_at = NOW(),
                worker_token = CAST(:workerToken AS uuid),
                updated_at = NOW()
            WHERE id IN (SELECT id FROM candidates)
            RETURNING id
            """)
    List<Long> claimBatch(@Param("batchSize") int batchSize,
                          @Param("leaseSecs") long leaseSecs,
                          @Param("workerToken") String workerToken);

    @Modifying
    @Query("""
            UPDATE AudioTask t SET t.leaseExpiresAt = :newLease, t.heartbeatAt = :now, t.updatedAt = :now
            WHERE t.id = :id
              AND t.status = com.jlpt_mono.app.entity.AudioTaskStatus.CLAIMED
              AND t.workerToken = :token
            """)
    int renewLease(@Param("id") Long id,
                   @Param("token") UUID token,
                   @Param("newLease") Instant newLease,
                   @Param("now") Instant now);

    @Modifying
    @Query("""
            UPDATE AudioTask t SET t.status = com.jlpt_mono.app.entity.AudioTaskStatus.SUCCEEDED,
                t.finishedAt = :now, t.updatedAt = :now
            WHERE t.id = :id
              AND t.status = com.jlpt_mono.app.entity.AudioTaskStatus.CLAIMED
              AND t.workerToken = :token
            """)
    int completeTask(@Param("id") Long id,
                     @Param("token") UUID token,
                     @Param("now") Instant now);

    @Modifying
    @Query("""
            UPDATE AudioTask t SET t.status = :terminalStatus,
                t.lastError = :error, t.finishedAt = :now, t.updatedAt = :now
            WHERE t.id = :id
              AND t.status = com.jlpt_mono.app.entity.AudioTaskStatus.CLAIMED
              AND t.workerToken = :token
            """)
    int markTaskFinishedIfOwned(@Param("id") Long id,
                                @Param("token") UUID token,
                                @Param("terminalStatus") AudioTaskStatus terminalStatus,
                                @Param("error") String error,
                                @Param("now") Instant now);

    @Modifying
    @Query("""
            UPDATE AudioTask t SET t.status = com.jlpt_mono.app.entity.AudioTaskStatus.ABANDONED,
                t.finishedAt = :now, t.updatedAt = :now
            WHERE t.id = :id
              AND t.status = com.jlpt_mono.app.entity.AudioTaskStatus.CLAIMED
              AND t.workerToken = :token
            """)
    int abandonTask(@Param("id") Long id,
                    @Param("token") UUID token,
                    @Param("now") Instant now);
}
