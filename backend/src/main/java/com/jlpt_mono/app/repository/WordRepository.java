package com.jlpt_mono.app.repository;

import com.jlpt_mono.app.entity.Word;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.util.Optional;

public interface WordRepository extends JpaRepository<Word, Long>, JpaSpecificationExecutor<Word> {

    @EntityGraph(attributePaths = "category")
    Optional<Word> findWithCategoryById(Long id);
}
