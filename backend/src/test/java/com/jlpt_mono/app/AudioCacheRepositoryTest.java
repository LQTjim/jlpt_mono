package com.jlpt_mono.app;

import com.jlpt_mono.app.entity.AudioCache;
import com.jlpt_mono.app.entity.AudioCacheStatus;
import com.jlpt_mono.app.entity.Word;
import com.jlpt_mono.app.repository.AudioCacheRepository;
import com.jlpt_mono.app.repository.WordRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@Import(TestcontainersConfiguration.class)
@SpringBootTest
@ActiveProfiles("test")
@Transactional
class AudioCacheRepositoryTest {

    @Autowired
    private AudioCacheRepository audioCacheRepository;

    @Autowired
    private WordRepository wordRepository;

    private Word word;

    @BeforeEach
    void setUp() {
        word = new Word();
        word.setHiragana("こんにちは");
        word.setJlptLevel("N5");
        wordRepository.save(word);
    }

    @Test
    @DisplayName("AudioCache 可成功儲存並透過 wordId + voiceId 查詢")
    void saveAndFindByWordIdAndVoiceId() {
        AudioCache cache = new AudioCache();
        cache.setWord(word);
        cache.setVoiceId("voice-001");
        cache.setSourceText("こんにちは");
        cache.setStatus(AudioCacheStatus.PENDING);
        audioCacheRepository.save(cache);

        Optional<AudioCache> found = audioCacheRepository.findByWordIdAndVoiceId(word.getId(), "voice-001");

        assertThat(found).isPresent();
        assertThat(found.get().getStatus()).isEqualTo(AudioCacheStatus.PENDING);
        assertThat(found.get().getCreatedAt()).isNotNull();
        assertThat(found.get().getUpdatedAt()).isNotNull();
    }

    @Test
    @DisplayName("相同 (vocabularyId, voiceId) 重複插入應違反 unique constraint")
    void duplicateVocabIdAndVoiceIdViolatesUniqueConstraint() {
        AudioCache first = new AudioCache();
        first.setWord(word);
        first.setVoiceId("voice-001");
        first.setSourceText("こんにちは");
        first.setStatus(AudioCacheStatus.PENDING);
        audioCacheRepository.saveAndFlush(first);

        AudioCache duplicate = new AudioCache();
        duplicate.setWord(word);
        duplicate.setVoiceId("voice-001");
        duplicate.setSourceText("こんにちは");
        duplicate.setStatus(AudioCacheStatus.PENDING);

        assertThatThrownBy(() -> audioCacheRepository.saveAndFlush(duplicate))
                .isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    @DisplayName("status 欄位可正確更新")
    void statusCanBeUpdated() {
        AudioCache cache = new AudioCache();
        cache.setWord(word);
        cache.setVoiceId("voice-002");
        cache.setSourceText("こんにちは");
        cache.setStatus(AudioCacheStatus.PENDING);
        audioCacheRepository.save(cache);

        cache.setStatus(AudioCacheStatus.READY);
        cache.setB2ObjectKey("voc/tts/1/voice-002.mp3");
        audioCacheRepository.saveAndFlush(cache);

        AudioCache updated = audioCacheRepository.findByWordIdAndVoiceId(word.getId(), "voice-002").orElseThrow();
        assertThat(updated.getStatus()).isEqualTo(AudioCacheStatus.READY);
        assertThat(updated.getB2ObjectKey()).isEqualTo("voc/tts/1/voice-002.mp3");
    }
}
