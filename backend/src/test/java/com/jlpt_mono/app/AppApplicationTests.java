package com.jlpt_mono.app;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 整合煙霧測試：驗證測試環境下 Spring ApplicationContext 能成功建立，
 * 並完成關鍵 schema 與 vocabulary seed bootstrap。
 * <ul>
 *   <li>{@link SpringBootTest}：載入與正式環境相近的完整 context（含自動設定、Bean 等）</li>
 *   <li>{@code @Import(TestcontainersConfiguration.class)}：一併載入 Testcontainers 的 Postgres，
 *       並透過 {@code @ServiceConnection} 讓 datasource 連到容器</li>
 *   <li>透過 {@link JdbcTemplate} 驗證核心資料表存在，且 vocabulary seed 已寫入資料</li>
 * </ul>
 */
@Import(TestcontainersConfiguration.class)
@SpringBootTest
@ActiveProfiles("test")
class AppApplicationTests {

	@Autowired
	private JdbcTemplate jdbcTemplate;

	@Test
	@DisplayName("應能以空資料庫啟動並完成關鍵 schema 與 seed bootstrap")
	void bootstrapCreatesSchemaAndSeedData() {
		assertThat(tableExists("users")).isTrue();
		assertThat(tableExists("refresh_tokens")).isTrue();
		assertThat(tableExists("categories")).isTrue();
		assertThat(tableExists("words")).isTrue();
		assertThat(tableExists("examples")).isTrue();
		assertThat(tableExists("word_relations")).isTrue();
		assertThat(tableExists("audio_cache")).isTrue();

		assertThat(countRows("categories")).isGreaterThan(0);
		assertThat(countRows("words")).isGreaterThan(0);
		assertThat(countRows("examples")).isGreaterThan(0);
	}

	private boolean tableExists(String tableName) {
		Integer count = jdbcTemplate.queryForObject(
				"""
				SELECT COUNT(*)
				FROM information_schema.tables
				WHERE table_schema = 'public' AND table_name = ?
				""",
				Integer.class,
				tableName);
		return count != null && count > 0;
	}

	private int countRows(String tableName) {
		Integer count = jdbcTemplate.queryForObject(
				"SELECT COUNT(*) FROM " + tableName,
				Integer.class);
		return count != null ? count : 0;
	}
}
