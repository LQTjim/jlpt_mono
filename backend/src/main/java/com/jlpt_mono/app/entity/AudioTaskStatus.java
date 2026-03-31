package com.jlpt_mono.app.entity;

public enum AudioTaskStatus {
    QUEUED,
    CLAIMED,
    SUCCEEDED,
    RETRYABLE_FAILED,
    DEAD_LETTER,
    ABANDONED
}
