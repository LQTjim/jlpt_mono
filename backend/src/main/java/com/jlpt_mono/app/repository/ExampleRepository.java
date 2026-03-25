package com.jlpt_mono.app.repository;

import com.jlpt_mono.app.entity.Example;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ExampleRepository extends JpaRepository<Example, Long> {

    List<Example> findByWordId(Long wordId);
}
