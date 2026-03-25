package com.jlpt_mono.app.repository;

import com.jlpt_mono.app.entity.WordRelation;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface WordRelationRepository extends JpaRepository<WordRelation, Long> {

    @EntityGraph(attributePaths = "relatedWord")
    List<WordRelation> findWithRelatedWordByWordId(Long wordId);
}
