package com.jlpt_mono.app.controller;

import com.jlpt_mono.app.dto.*;
import com.jlpt_mono.app.service.QuizService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/quiz")
public class QuizController {

    private final QuizService quizService;

    public QuizController(QuizService quizService) {
        this.quizService = quizService;
    }

    @PostMapping("/start")
    public ResponseEntity<QuizStartResponse> startQuiz(
            Authentication authentication,
            @Valid @RequestBody QuizStartRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        return ResponseEntity.ok(quizService.startQuiz(userId, request));
    }

    @PostMapping("/{sessionId}/submit")
    public ResponseEntity<QuizSubmitResponse> submitQuiz(
            Authentication authentication,
            @PathVariable Long sessionId,
            @Valid @RequestBody QuizSubmitRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        return ResponseEntity.ok(quizService.submitQuiz(userId, sessionId, request));
    }

    @GetMapping("/history")
    public ResponseEntity<PageResponse<QuizHistoryResponse>> getHistory(
            Authentication authentication,
            @PageableDefault(size = 10, sort = "completedAt", direction = Sort.Direction.DESC) Pageable pageable) {
        Long userId = (Long) authentication.getPrincipal();
        return ResponseEntity.ok(PageResponse.from(quizService.getHistory(userId, pageable)));
    }
}
