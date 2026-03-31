package com.jlpt_mono.app.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.time.Duration;

@Component
@ConfigurationProperties("app.audio.queue")
public class AudioQueueProperties {

    private Duration dispatchInterval = Duration.ofSeconds(5);
    private int dispatchBatch = 5;
    private Duration recoveryInterval = Duration.ofSeconds(60);
    private int recoveryBatch = 20;
    private int startupRecoveryBatch = 50;
    private Duration leaseDuration = Duration.ofSeconds(120);
    private Duration heartbeatInterval = Duration.ofSeconds(20);
    private int workerConcurrency = 3;
    private int maxAttempts = 5;

    public Duration getDispatchInterval() { return dispatchInterval; }
    public void setDispatchInterval(Duration dispatchInterval) { this.dispatchInterval = dispatchInterval; }

    public int getDispatchBatch() { return dispatchBatch; }
    public void setDispatchBatch(int dispatchBatch) { this.dispatchBatch = dispatchBatch; }

    public Duration getRecoveryInterval() { return recoveryInterval; }
    public void setRecoveryInterval(Duration recoveryInterval) { this.recoveryInterval = recoveryInterval; }

    public int getRecoveryBatch() { return recoveryBatch; }
    public void setRecoveryBatch(int recoveryBatch) { this.recoveryBatch = recoveryBatch; }

    public int getStartupRecoveryBatch() { return startupRecoveryBatch; }
    public void setStartupRecoveryBatch(int startupRecoveryBatch) { this.startupRecoveryBatch = startupRecoveryBatch; }

    public Duration getLeaseDuration() { return leaseDuration; }
    public void setLeaseDuration(Duration leaseDuration) { this.leaseDuration = leaseDuration; }

    public Duration getHeartbeatInterval() { return heartbeatInterval; }
    public void setHeartbeatInterval(Duration heartbeatInterval) { this.heartbeatInterval = heartbeatInterval; }

    public int getWorkerConcurrency() { return workerConcurrency; }
    public void setWorkerConcurrency(int workerConcurrency) { this.workerConcurrency = workerConcurrency; }

    public int getMaxAttempts() { return maxAttempts; }
    public void setMaxAttempts(int maxAttempts) { this.maxAttempts = maxAttempts; }
}
