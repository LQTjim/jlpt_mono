package com.jlpt_mono.app.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.net.URI;

@Component
@ConfigurationProperties(prefix = "app.storage.b2")
public class B2StorageProperties {

    private String endpoint;
    private String bucket;
    private String accessKey;
    private String secretKey;
    private long presignExpirationSeconds = 900;

    /**
     * Derives the region from the B2 endpoint hostname.
     * e.g. "https://s3.us-west-004.backblazeb2.com" → "us-west-004"
     */
    public String getRegion() {
        String host = URI.create(endpoint).getHost(); // s3.us-west-004.backblazeb2.com
        return host.split("\\.")[1];
    }

    public String getEndpoint() {
        return endpoint;
    }

    public void setEndpoint(String endpoint) {
        this.endpoint = endpoint;
    }

    public String getBucket() {
        return bucket;
    }

    public void setBucket(String bucket) {
        this.bucket = bucket;
    }

    public String getAccessKey() {
        return accessKey;
    }

    public void setAccessKey(String accessKey) {
        this.accessKey = accessKey;
    }

    public String getSecretKey() {
        return secretKey;
    }

    public void setSecretKey(String secretKey) {
        this.secretKey = secretKey;
    }

    public long getPresignExpirationSeconds() {
        return presignExpirationSeconds;
    }

    public void setPresignExpirationSeconds(long presignExpirationSeconds) {
        this.presignExpirationSeconds = presignExpirationSeconds;
    }
}
