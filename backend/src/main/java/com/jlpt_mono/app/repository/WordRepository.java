package com.jlpt_mono.app.repository;

import com.jlpt_mono.app.entity.Word;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface WordRepository extends JpaRepository<Word, Long>, JpaSpecificationExecutor<Word> {

    @EntityGraph(attributePaths = "category")
    Optional<Word> findWithCategoryById(Long id);

    @Query(value = "SELECT * FROM words WHERE jlpt_level = :jlptLevel ORDER BY RANDOM() LIMIT :limit",
            nativeQuery = true)
    List<Word> findRandomByJlptLevel(String jlptLevel, int limit);

    @Query(value = """
            SELECT * FROM words w
            WHERE w.jlpt_level = :jlptLevel AND w.id NOT IN (:excludeIds)
            ORDER BY RANDOM() LIMIT :limit
            """, nativeQuery = true)
    List<Word> findRandomByJlptLevelExcluding(String jlptLevel, List<Long> excludeIds, int limit);

    @Query(value = """
            SELECT * FROM words w
            WHERE w.jlpt_level = :jlptLevel AND w.id != :excludeId
            ORDER BY RANDOM() LIMIT :limit
            """, nativeQuery = true)
    List<Word> findRandomDistractors(String jlptLevel, Long excludeId, int limit);

    @Query(value = """
            SELECT w.* FROM words w
            WHERE w.jlpt_level = :jlptLevel
              AND EXISTS (SELECT 1 FROM examples e WHERE e.word_id = w.id)
            ORDER BY RANDOM() LIMIT :limit
            """, nativeQuery = true)
    List<Word> findRandomWithExamplesByJlptLevel(String jlptLevel, int limit);
}
