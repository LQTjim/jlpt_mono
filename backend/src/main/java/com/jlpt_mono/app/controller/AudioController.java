package com.jlpt_mono.app.controller;

import com.jlpt_mono.app.dto.AudioResponse;
import com.jlpt_mono.app.service.AudioService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/audio")
public class AudioController {

    private final AudioService audioService;

    public AudioController(AudioService audioService) {
        this.audioService = audioService;
    }

    @PostMapping("/generate/{vocabularyId}")
    public ResponseEntity<AudioResponse> generate(@PathVariable Long vocabularyId) {
        AudioResponse response = audioService.generateAudio(vocabularyId);
        return switch (response.status()) {
            case "PENDING", "PROCESSING" -> ResponseEntity.accepted().body(response);
            default -> ResponseEntity.ok(response); // READY or FAILED — terminal, let client decide
        };
    }

    @GetMapping("/status/{jobId}")
    public ResponseEntity<AudioResponse> status(@PathVariable Long jobId) {
        return ResponseEntity.ok(audioService.getStatus(jobId));
    }
}
