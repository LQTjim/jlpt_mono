-- Quiz session: one per quiz attempt
CREATE TABLE quiz_sessions (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id),
    jlpt_level      VARCHAR(2) NOT NULL CHECK (jlpt_level IN ('N1','N2','N3','N4','N5')),
    score           INT,
    total           INT NOT NULL DEFAULT 10,
    completed_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_quiz_sessions_user_id ON quiz_sessions(user_id);
CREATE INDEX idx_quiz_sessions_completed_at ON quiz_sessions(completed_at);

-- Quiz question: each question in a session
CREATE TABLE quiz_questions (
    id              BIGSERIAL PRIMARY KEY,
    session_id      BIGINT NOT NULL REFERENCES quiz_sessions(id) ON DELETE CASCADE,
    seq             INT NOT NULL,
    type            VARCHAR(20) NOT NULL CHECK (type IN ('MEANING','REVERSE','SENTENCE_FILL')),
    word_id         BIGINT NOT NULL REFERENCES words(id),
    example_id      BIGINT REFERENCES examples(id),
    correct_key     VARCHAR(1) NOT NULL CHECK (correct_key IN ('A','B','C','D')),
    options         JSONB NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_quiz_questions_session_id ON quiz_questions(session_id);

-- Quiz answer: user's answer to each question
CREATE TABLE quiz_answers (
    id              BIGSERIAL PRIMARY KEY,
    question_id     BIGINT NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,
    selected_key    VARCHAR(1),
    correct         BOOLEAN NOT NULL,
    answered_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_quiz_answers_question_id ON quiz_answers(question_id);
