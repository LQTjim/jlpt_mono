package com.jlpt_mono.app.service;

import com.jlpt_mono.app.config.B2StorageProperties;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectResponse;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.GetObjectPresignRequest;
import software.amazon.awssdk.services.s3.presigner.model.PresignedGetObjectRequest;

import java.net.MalformedURLException;
import java.net.URL;

import software.amazon.awssdk.services.s3.model.HeadObjectRequest;
import software.amazon.awssdk.services.s3.model.NoSuchKeyException;
import software.amazon.awssdk.services.s3.model.S3Exception;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class B2StorageClientTest {

    @Mock
    private S3Client s3Client;

    @Mock
    private S3Presigner s3Presigner;

    private B2StorageClient client;

    @BeforeEach
    void setUp() {
        B2StorageProperties props = new B2StorageProperties();
        props.setEndpoint("https://s3.us-west-004.backblazeb2.com");
        props.setBucket("test-bucket");
        props.setAccessKey("test-access-key");
        props.setSecretKey("test-secret-key");
        props.setPresignExpirationSeconds(900);

        client = new B2StorageClient(s3Client, s3Presigner, props);
    }

    @Test
    @DisplayName("uploadAudio 應以正確的 bucket、key 和 content-type 呼叫 S3Client")
    void uploadAudio_callsPutObjectWithCorrectParams() {
        when(s3Client.putObject(any(PutObjectRequest.class), any(RequestBody.class)))
                .thenReturn(PutObjectResponse.builder().build());

        client.uploadAudio("voc/tts/1/voice.mp3", new byte[]{1, 2, 3});

        ArgumentCaptor<PutObjectRequest> captor = ArgumentCaptor.forClass(PutObjectRequest.class);
        verify(s3Client).putObject(captor.capture(), any(RequestBody.class));

        PutObjectRequest req = captor.getValue();
        assertThat(req.bucket()).isEqualTo("test-bucket");
        assertThat(req.key()).isEqualTo("voc/tts/1/voice.mp3");
        assertThat(req.contentType()).isEqualTo("audio/mpeg");
    }

    @Test
    @DisplayName("generatePresignedUrl 應回傳 presigner 產生的 URL 字串")
    void generatePresignedUrl_returnsPresignedUrlString() throws MalformedURLException {
        PresignedGetObjectRequest presignedRequest = mockPresignedRequest("https://s3.us-west-004.backblazeb2.com/test-bucket/voc/tts/1/voice.mp3?sig=abc");
        when(s3Presigner.presignGetObject(any(GetObjectPresignRequest.class)))
                .thenReturn(presignedRequest);

        String url = client.generatePresignedUrl("voc/tts/1/voice.mp3");

        assertThat(url).contains("voc/tts/1/voice.mp3");
        verify(s3Presigner).presignGetObject(any(GetObjectPresignRequest.class));
    }

    @Test
    @DisplayName("objectExists — NoSuchKeyException 時應回傳 false")
    void objectExists_noSuchKey_returnsFalse() {
        when(s3Client.headObject(any(HeadObjectRequest.class)))
                .thenThrow(NoSuchKeyException.builder().build());

        assertThat(client.objectExists("voc/tts/1/voice.mp3")).isFalse();
    }

    @Test
    @DisplayName("objectExists — S3Exception HTTP 404 時應回傳 false（B2 回傳方式）")
    void objectExists_s3Exception404_returnsFalse() {
        when(s3Client.headObject(any(HeadObjectRequest.class)))
                .thenThrow(S3Exception.builder().statusCode(404).build());

        assertThat(client.objectExists("voc/tts/1/voice.mp3")).isFalse();
    }

    @Test
    @DisplayName("objectExists — S3Exception 非 404 時應重新拋出")
    void objectExists_s3ExceptionNon404_rethrows() {
        when(s3Client.headObject(any(HeadObjectRequest.class)))
                .thenThrow(S3Exception.builder().statusCode(403).build());

        assertThatThrownBy(() -> client.objectExists("voc/tts/1/voice.mp3"))
                .isInstanceOf(S3Exception.class);
    }

    private PresignedGetObjectRequest mockPresignedRequest(String urlString) throws MalformedURLException {
        PresignedGetObjectRequest mock = org.mockito.Mockito.mock(PresignedGetObjectRequest.class);
        when(mock.url()).thenReturn(new URL(urlString));
        return mock;
    }
}
