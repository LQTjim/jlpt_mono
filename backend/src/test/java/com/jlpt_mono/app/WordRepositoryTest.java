package com.jlpt_mono.app;

import com.jlpt_mono.app.entity.Word;
import com.jlpt_mono.app.repository.ExampleRepository;
import com.jlpt_mono.app.repository.WordRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;

@Import(TestcontainersConfiguration.class)
@SpringBootTest
@ActiveProfiles("test")
@Transactional
class WordRepositoryTest {

    @Autowired private WordRepository wordRepository;
    @Autowired private ExampleRepository exampleRepository;

    @Test
    @DisplayName("findRandomByJlptLevel: 回傳指定數量且全為 N5")
    void findRandomByJlptLevel_returnsRequestedCount() {
        List<Word> result = wordRepository.findRandomByJlptLevel("N5", 10);

        assertThat(result).hasSize(10);
        assertThat(result).allMatch(w -> "N5".equals(w.getJlptLevel()));
    }

    @Test
    @DisplayName("findRandomByJlptLevel: limit 小於可用數量時精確回傳 limit")
    void findRandomByJlptLevel_respectsLimit() {
        List<Word> result = wordRepository.findRandomByJlptLevel("N5", 3);

        assertThat(result).hasSize(3);
    }

    @Test
    @DisplayName("findRandomDistractors: 排除指定 word，其餘皆為同等級")
    void findRandomDistractors_excludesTargetAndReturnsCorrectLevel() {
        Long excludeId = wordRepository.findRandomByJlptLevel("N5", 1).get(0).getId();

        List<Word> result = wordRepository.findRandomDistractors("N5", excludeId, 3);

        assertThat(result).hasSize(3);
        assertThat(result).allMatch(w -> "N5".equals(w.getJlptLevel()));
        assertThat(result).noneMatch(w -> w.getId().equals(excludeId));
    }

    @Test
    @DisplayName("findRandomByJlptLevelExcluding: 排除多個 IDs 後結果中不含任何被排除的 ID")
    void findRandomByJlptLevelExcluding_excludesAllSpecifiedIds() {
        List<Long> excludeIds = wordRepository.findRandomByJlptLevel("N5", 5)
                .stream().map(Word::getId).toList();

        List<Word> result = wordRepository.findRandomByJlptLevelExcluding("N5", excludeIds, 5);

        assertThat(result).hasSize(5);
        Set<Long> resultIds = result.stream().map(Word::getId).collect(Collectors.toSet());
        assertThat(resultIds).doesNotContainAnyElementsOf(excludeIds);
    }

    @Test
    @DisplayName("findRandomWithExamplesByJlptLevel: 每筆結果都有例句")
    void findRandomWithExamplesByJlptLevel_allResultsHaveExamples() {
        List<Word> result = wordRepository.findRandomWithExamplesByJlptLevel("N5", 5);

        assertThat(result).hasSize(5);
        for (Word w : result) {
            assertThat(exampleRepository.findByWordId(w.getId()))
                    .as("Word %d should have at least one example", w.getId())
                    .isNotEmpty();
        }
    }
}
