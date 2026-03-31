ALTER TABLE audio_cache ADD COLUMN processing_started_at TIMESTAMPTZ;

CREATE TABLE audio_task (
    id               BIGSERIAL PRIMARY KEY,
    audio_cache_id   BIGINT NOT NULL REFERENCES audio_cache(id),
    status           VARCHAR(20) NOT NULL
                     CHECK (status IN ('QUEUED','CLAIMED','SUCCEEDED','RETRYABLE_FAILED','DEAD_LETTER','ABANDONED')),
    priority         VARCHAR(20) NOT NULL CHECK (priority IN ('INTERACTIVE','RECOVERY')),
    origin           VARCHAR(20) NOT NULL CHECK (origin IN ('USER','SCHEDULER','STARTUP')),
    attempt_no       INT NOT NULL DEFAULT 1,
    available_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    claimed_at       TIMESTAMPTZ,
    lease_expires_at TIMESTAMPTZ,
    heartbeat_at     TIMESTAMPTZ,
    worker_token     UUID,
    last_error       TEXT,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    finished_at      TIMESTAMPTZ
);

CREATE INDEX idx_audio_task_claim ON audio_task(status, available_at, priority, created_at)
    WHERE status IN ('QUEUED', 'CLAIMED');

CREATE INDEX idx_audio_task_audio_cache_id ON audio_task(audio_cache_id);

CREATE UNIQUE INDEX uq_audio_task_active_per_cache ON audio_task(audio_cache_id)
    WHERE status IN ('QUEUED', 'CLAIMED');
