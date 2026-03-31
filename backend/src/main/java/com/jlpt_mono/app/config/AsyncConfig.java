package com.jlpt_mono.app.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;

@Configuration
@EnableAsync
@EnableScheduling
public class AsyncConfig {

    @Bean(name = "workerExecutor")
    public Executor workerExecutor(AudioQueueProperties props) {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(props.getWorkerConcurrency());
        executor.setMaxPoolSize(props.getWorkerConcurrency());
        executor.setQueueCapacity(props.getDispatchBatch() * 4);
        executor.setThreadNamePrefix("tts-worker-");
        executor.initialize();
        return executor;
    }

    @Bean(name = "heartbeatExecutor")
    public ScheduledExecutorService heartbeatExecutor() {
        return Executors.newScheduledThreadPool(2, r -> {
            Thread t = new Thread(r, "tts-heartbeat-" + System.nanoTime());
            t.setDaemon(true);
            return t;
        });
    }
}
