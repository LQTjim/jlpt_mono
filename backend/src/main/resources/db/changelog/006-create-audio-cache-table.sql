CREATE TABLE audio_cache (
    id              BIGSERIAL PRIMARY KEY,
    vocabulary_id   BIGINT NOT NULL REFERENCES words(id),
    voice_id        VARCHAR(100) NOT NULL,
    source_text     VARCHAR(255) NOT NULL,
    status          VARCHAR(20) NOT NULL CHECK (status IN ('PENDING', 'PROCESSING', 'READY', 'FAILED')),
    b2_object_key   VARCHAR(512),
    last_error      TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_audio_cache_vocab_voice UNIQUE (vocabulary_id, voice_id)
);

CREATE INDEX idx_audio_cache_vocabulary_id ON audio_cache(vocabulary_id);
