package com.jlpt_mono.app.service;

import com.jlpt_mono.app.config.ElevenLabsProperties;
import com.jlpt_mono.app.exception.TtsException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.*;
import static org.springframework.test.web.client.response.MockRestResponseCreators.*;

class ElevenLabsClientTest {

    private MockRestServiceServer server;
    private ElevenLabsClient client;

    @BeforeEach
    void setUp() {
        ElevenLabsProperties props = new ElevenLabsProperties();
        props.setApiKey("test-api-key");
        props.setVoiceId("test-voice-id");
        props.setModelId("eleven_multilingual_v2");
        props.setBaseUrl("https://api.elevenlabs.io");

        RestClient.Builder builder = RestClient.builder();
        server = MockRestServiceServer.bindTo(builder).build();
        client = new ElevenLabsClient(builder.baseUrl(props.getBaseUrl()).build(), props);
    }

    @Test
    @DisplayName("generateSpeech 應帶正確 header 並回傳音訊 bytes")
    void generateSpeech_sendsCorrectHeadersAndReturnsBytes() {
        byte[] fakeAudio = new byte[]{(byte) 0xFF, (byte) 0xFB, 0x10, 0x00};
        server.expect(requestTo("https://api.elevenlabs.io/v1/text-to-speech/test-voice-id"))
                .andExpect(method(HttpMethod.POST))
                .andExpect(header("xi-api-key", "test-api-key"))
                .andExpect(header("Accept", "audio/mpeg"))
                .andRespond(withSuccess(fakeAudio, MediaType.parseMediaType("audio/mpeg")));

        byte[] result = client.generateSpeech("こんにちは");

        assertThat(result).isEqualTo(fakeAudio);
        server.verify();
    }

    @Test
    @DisplayName("generateSpeech 收到 4xx 時應拋出 TtsException")
    void generateSpeech_on4xx_throwsTtsException() {
        server.expect(requestTo("https://api.elevenlabs.io/v1/text-to-speech/test-voice-id"))
                .andExpect(method(HttpMethod.POST))
                .andRespond(withStatus(HttpStatus.UNAUTHORIZED));

        assertThatThrownBy(() -> client.generateSpeech("こんにちは"))
                .isInstanceOf(TtsException.class)
                .hasMessageContaining("401");
        server.verify();
    }

    @Test
    @DisplayName("generateSpeech 收到 5xx 時應拋出 TtsException")
    void generateSpeech_on5xx_throwsTtsException() {
        server.expect(requestTo("https://api.elevenlabs.io/v1/text-to-speech/test-voice-id"))
                .andExpect(method(HttpMethod.POST))
                .andRespond(withServerError());

        assertThatThrownBy(() -> client.generateSpeech("こんにちは"))
                .isInstanceOf(TtsException.class);
        server.verify();
    }
}
