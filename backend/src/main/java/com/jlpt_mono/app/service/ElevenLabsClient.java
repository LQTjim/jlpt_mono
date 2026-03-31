package com.jlpt_mono.app.service;

import com.jlpt_mono.app.config.ElevenLabsProperties;
import com.jlpt_mono.app.exception.TtsException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;

import java.util.Map;

@Component
public class ElevenLabsClient {

    private final RestClient restClient;
    private final ElevenLabsProperties properties;

    @Autowired
    public ElevenLabsClient(ElevenLabsProperties properties) {
        this(RestClient.builder().baseUrl(properties.getBaseUrl()).build(), properties);
    }

    // package-private for tests
    ElevenLabsClient(RestClient restClient, ElevenLabsProperties properties) {
        this.restClient = restClient;
        this.properties = properties;
    }

    public byte[] generateSpeech(String text) {
        try {
            return restClient.post()
                    .uri("/v1/text-to-speech/{voiceId}", properties.getVoiceId())
                    .header("xi-api-key", properties.getApiKey())
                    .header("Content-Type", "application/json")
                    .header("Accept", "audio/mpeg")
                    .body(Map.of("text", text, "model_id", properties.getModelId()))
                    .retrieve()
                    .body(byte[].class);
        } catch (RestClientResponseException e) {
            int code = e.getStatusCode().value();
            boolean retryable = code == 429 || code >= 500;
            throw new TtsException(
                    "ElevenLabs API error: status=" + e.getStatusCode(), e, retryable);
        } catch (Exception e) {
            throw new TtsException("ElevenLabs request failed: " + e.getMessage(), e, true);
        }
    }
}
