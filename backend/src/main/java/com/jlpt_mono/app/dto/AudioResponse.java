package com.jlpt_mono.app.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.Instant;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record AudioResponse(
        String status,
        Long jobId,
        String presignedUrl,
        Instant expiresAt,
        String errorMessage
) {

    public static AudioResponse ready(Long jobId, String presignedUrl, Instant expiresAt) {
        return new AudioResponse("READY", jobId, presignedUrl, expiresAt, null);
    }

    public static AudioResponse inProgress(Long jobId, String status) {
        return new AudioResponse(status, jobId, null, null, null);
    }

    public static AudioResponse failed(Long jobId, String errorMessage) {
        return new AudioResponse("FAILED", jobId, null, null, errorMessage);
    }
}
