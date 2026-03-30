package com.jlpt_mono.app.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "quiz_sessions")
@Getter
@Setter
@NoArgsConstructor
public class QuizSession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)// 自增主键
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)// 懒加载 預設是EAGER 會把user全部加載進來
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "jlpt_level", nullable = false, length = 2)
    private String jlptLevel;

    private Integer score;

    @Column(nullable = false)
    private int total = 10;

    @Column(name = "completed_at")
    private Instant completedAt;

    @Column(name = "created_at", updatable = false)
    private Instant createdAt;

    @OneToMany(mappedBy = "session", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @OrderBy("seq ASC")
    private List<QuizQuestion> questions = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        createdAt = Instant.now();
    }
}
