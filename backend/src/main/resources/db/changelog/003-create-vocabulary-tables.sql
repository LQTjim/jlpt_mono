-- Japanese Vocabulary Database Schema
-- Created for jpvacab project

-- =============================================
-- ENUM Types (using CHECK constraints for flexibility)
-- =============================================

-- =============================================
-- Tables
-- =============================================

-- Categories table (hierarchical)
CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    name_jp VARCHAR(100),
    name_zh VARCHAR(100),
    name_en VARCHAR(100),
    parent_id BIGINT REFERENCES categories(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Words main table
CREATE TABLE words (
    id BIGSERIAL PRIMARY KEY,
    kanji VARCHAR(100),
    hiragana VARCHAR(100) NOT NULL,
    romaji VARCHAR(100),
    definition_zh TEXT,
    definition_en TEXT,
    part_of_speech VARCHAR(50) CHECK (part_of_speech IN (
        'noun', 'verb', 'i-adjective', 'na-adjective',
        'adverb', 'particle', 'conjunction', 'interjection',
        'counter', 'prefix', 'suffix'
    )),
    verb_type VARCHAR(50) CHECK (verb_type IN (
        'godan', 'ichidan', 'irregular'
    )),
    jlpt_level VARCHAR(2) CHECK (jlpt_level IN ('N5', 'N4', 'N3', 'N2', 'N1')),
    category_id BIGINT REFERENCES categories(id) ON DELETE SET NULL,
    difficulty_score SMALLINT CHECK (difficulty_score >= 1 AND difficulty_score <= 10),
    frequency_rank INTEGER,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Examples table
CREATE TABLE examples (
    id BIGSERIAL PRIMARY KEY,
    word_id BIGINT NOT NULL REFERENCES words(id) ON DELETE CASCADE,
    sentence_jp TEXT NOT NULL,
    sentence_zh TEXT,
    sentence_en TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Word relations table (synonyms/antonyms)
CREATE TABLE word_relations (
    id BIGSERIAL PRIMARY KEY,
    word_id BIGINT NOT NULL REFERENCES words(id) ON DELETE CASCADE,
    related_word_id BIGINT NOT NULL REFERENCES words(id) ON DELETE CASCADE,
    relation_type VARCHAR(20) CHECK (relation_type IN ('synonym', 'antonym')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(word_id, related_word_id, relation_type)
);

-- =============================================
-- Indexes
-- =============================================

-- Words table indexes
CREATE INDEX idx_words_kanji ON words(kanji);
CREATE INDEX idx_words_hiragana ON words(hiragana);
CREATE INDEX idx_words_jlpt_level ON words(jlpt_level);
CREATE INDEX idx_words_category_id ON words(category_id);
CREATE INDEX idx_words_part_of_speech ON words(part_of_speech);
CREATE INDEX idx_words_frequency_rank ON words(frequency_rank);

-- Examples table indexes
CREATE INDEX idx_examples_word_id ON examples(word_id);

-- Word relations table indexes
CREATE INDEX idx_word_relations_word_id ON word_relations(word_id);
CREATE INDEX idx_word_relations_related_word_id ON word_relations(related_word_id);

-- Categories table indexes
CREATE INDEX idx_categories_parent_id ON categories(parent_id);

