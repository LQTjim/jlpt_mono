# TODO

## Testing

- [ ] DataJpaTest: 用 TestContainers + PostgreSQL 驗證 native queries (`findRandomByJlptLevel`, `findRandomDistractors`, `findRandomWithExamplesByJlptLevel`, `findRandomByJlptLevelExcluding`) 能在真實 DB 上執行
- [ ] Quiz integration test: TestContainers 環境下跑 start → submit 全流程，驗證 session 建立、題目生成、答案提交、分數計算、歷史查詢的端到端正確性
