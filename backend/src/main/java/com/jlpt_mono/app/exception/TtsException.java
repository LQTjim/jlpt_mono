package com.jlpt_mono.app.exception;

public class TtsException extends RuntimeException {

    private final boolean retryable;

    public TtsException(String message, Throwable cause, boolean retryable) {
        super(message, cause);
        this.retryable = retryable;
    }

    public boolean isRetryable() {
        return retryable;
    }
}
