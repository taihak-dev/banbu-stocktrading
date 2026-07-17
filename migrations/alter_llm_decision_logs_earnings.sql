-- llm_decision_logs 실적(earnings) 컬럼 추가
-- 배경: llm_review_service._save_llm_decision_logs() 의 upsert payload 에
--   earnings_date / days_to_earnings / earnings_estimate 가 포함되는데
--   테이블에 해당 컬럼이 없으면 PostgREST 가 400(PGRST204)로 저장 실패한다.
-- 적용: Supabase Dashboard → SQL Editor 에서 실행 (IF NOT EXISTS 라 재실행 안전).

ALTER TABLE llm_decision_logs ADD COLUMN IF NOT EXISTS earnings_date      DATE;           -- 실적 발표일 (YYYY-MM-DD)
ALTER TABLE llm_decision_logs ADD COLUMN IF NOT EXISTS days_to_earnings   INTEGER;        -- 실적까지 남은 일수 (D-day)
ALTER TABLE llm_decision_logs ADD COLUMN IF NOT EXISTS earnings_estimate  DECIMAL(10, 2); -- 예상 EPS
