# DB 마이그레이션 (Supabase / PostgreSQL)

이 폴더는 `db_backup/schema/`(gitignore, JWT 토큰 포함 `.json` 스냅샷 보관)에서 옮겨온
스키마 SQL(DDL)을 모아둔 곳입니다. Supabase Dashboard → **SQL Editor**에 붙여넣어 실행합니다.

## 적용 순서 (새 DB 세팅 시)

아래 순서대로 실행하세요. 대부분 `IF NOT EXISTS` / `IF EXISTS`라 여러 번 실행해도 안전(idempotent)합니다.

### 1단계 — 베이스 테이블 생성
| 순서 | 파일 | 내용 |
|---|---|---|
| 1 | `create_all_tables.sql` | 핵심 8개 테이블 생성: `economic_and_stock_data`, `stock_analysis_results`, `predicted_stocks`, `stock_recommendations`, `ticker_sentiment_analysis`, `trade_records`, `llm_decision_logs`, `access_tokens`. (이미 `holding_quantity` · `account_type` 인덱스 · `daily_change_pct` 포함) |
| 2 | `create_signal_snapshots.sql` | `signal_snapshots` 테이블 (베이스에 미포함) |

### 2단계 — 컬럼/인덱스 변경 (ALTER)
테이블이 존재해야 하므로 1단계 이후 실행합니다. 파일 간 순서는 무관합니다.

| 파일 | 대상 | 비고 |
|---|---|---|
| `alter_trade_records_trail_high.sql` | `trade_records` | `trail_high` 추가 (트레일링 스톱용). **베이스 미포함 → 필수** |
| `alter_llm_decision_logs_earnings.sql` | `llm_decision_logs` | `earnings_date` · `days_to_earnings` · `earnings_estimate` 추가. **베이스 미포함 → 필수** (없으면 LLM 판단 로그 저장이 PGRST204/400로 실패) |
| `alter_stock_analysis_results_schema.sql` | `stock_analysis_results` | 구 컬럼 정리 + 신 컬럼 추가. idempotent, 안전하게 재적용 가능 |
| `alter_trade_records_account_type.sql` | `trade_records` | `account_type` 컬럼/인덱스. **이미 베이스에 포함** → 재실행해도 no-op(안전) |
| `alter_trade_records_holding_quantity.sql` | `trade_records` | `holding_quantity`. **이미 베이스에 포함** → no-op(안전) |

## 레거시 (새 DB에서는 실행하지 마세요)

아래 두 파일은 `create_all_tables.sql`로 **대체됨**. `CREATE TABLE`에 `IF NOT EXISTS`가 없어
베이스 적용 후 실행하면 "already exists" 오류가 납니다. 이력/참고용으로만 보관합니다.

- `create_trade_records.sql` — `trade_records` 단독 생성 (구버전)
- `create_llm_decision_logs.sql` — `llm_decision_logs` 단독 생성 + `stock_recommendations.daily_change_pct` (둘 다 베이스에 이미 반영)

## 참고
- 실제 데이터 덤프(`.csv`/`.json`)와 토큰이 든 스키마 스냅샷은 `db_backup/`에 있으며 `.gitignore`로 제외됩니다.
- 앞으로 스키마 변경은 이 폴더에 `alter_<table>_<변경>.sql` 형태로 추가하세요.
