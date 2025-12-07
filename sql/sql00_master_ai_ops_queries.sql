
use ai_call_quality;
WITH base AS (
  SELECT
    callsid,
    call_date,
    call_duration_sec,
    COALESCE(asr_errors,0) AS asr_errors,
    COALESCE(incorrect_responses,0) AS incorrect_responses,
    COALESCE(repetition_by_bot,0) AS repetition_by_bot,
    COALESCE(interruption_handling_error,0) AS interruption_handling_error,
    COALESCE(hallucination_error,0) AS hallucination_error,
    (COALESCE(asr_errors,0)+COALESCE(incorrect_responses,0)+COALESCE(repetition_by_bot,0)+COALESCE(interruption_handling_error,0)+COALESCE(hallucination_error,0)) AS total_errors,
    CASE WHEN (COALESCE(asr_errors,0)+COALESCE(incorrect_responses,0)+COALESCE(repetition_by_bot,0)+COALESCE(interruption_handling_error,0)+COALESCE(hallucination_error,0))>0 THEN 1 ELSE 0 END AS any_error
  FROM synthetic_calls
)
SELECT
  call_date,
  COUNT(*) AS total_calls,
  SUM(any_error) AS calls_with_any_error,
  SUM(CASE WHEN total_errors > 2 THEN 1 ELSE 0 END) AS calls_more_than_2_errors,
  ROUND(AVG(call_duration_sec),2) AS avg_duration_sec,
  SUM(asr_errors) AS total_asr_errors,
  SUM(incorrect_responses) AS total_incorrect,
  SUM(hallucination_error) AS total_hallucination,
  ROUND(AVG(total_errors),3) AS avg_errors_per_call,
  SUM(total_errors) AS total_errors_all_calls
FROM base
GROUP BY call_date
ORDER BY call_date;

WITH
base AS (
SELECT
call_date,
call_duration_sec,
COALESCE(asr_errors,0) AS asr_errors,
COALESCE(incorrect_responses,0) AS incorrect_responses,
COALESCE(repetition_by_bot,0) AS repetition_by_bot,
COALESCE(interruption_handling_error,0) AS interruption_handling_error,
COALESCE(hallucination_error,0) AS hallucination_error,
(COALESCE(asr_errors,0)+COALESCE(incorrect_responses,0)+COALESCE(repetition_by_bot,0)+COALESCE(interruption_handling_error,0)+COALESCE(hallucination_error,0)) AS total_errors,
CASE WHEN (COALESCE(asr_errors,0)+COALESCE(incorrect_responses,0)+COALESCE(repetition_by_bot,0)+COALESCE(interruption_handling_error,0)+COALESCE(hallucination_error,0))>0 THEN 1 ELSE 0 END AS any_error
FROM synthetic_calls
)
SELECT
DATE_FORMAT(call_date, '%x-W%v') AS iso_week,
COUNT(*) AS total_calls,
SUM(any_error) AS calls_with_any_error,
ROUND(AVG(call_duration_sec),2) AS avg_duration_sec,
SUM(total_errors) AS total_errors_all_calls,
ROUND(AVG(total_errors),3) AS avg_errors_per_call
FROM base
GROUP BY iso_week
ORDER BY iso_week;

SELECT 'asr_errors' AS error_type, SUM(asr_errors) AS total_count, ROUND(AVG(asr_errors),6) AS avg_per_call FROM synthetic_calls
UNION ALL
SELECT 'incorrect_responses', SUM(incorrect_responses), ROUND(AVG(incorrect_responses),6) FROM synthetic_calls
UNION ALL
SELECT 'repetition_by_bot', SUM(repetition_by_bot), ROUND(AVG(repetition_by_bot),6) FROM synthetic_calls
UNION ALL
SELECT 'interruption_handling_error', SUM(interruption_handling_error), ROUND(AVG(interruption_handling_error),6) FROM synthetic_calls
UNION ALL
SELECT 'hallucination_error', SUM(hallucination_error), ROUND(AVG(hallucination_error),6) FROM synthetic_calls;

SELECT
t1.err AS err_a,
t2.err AS err_b,
SUM(CASE WHEN
(CASE t1.err WHEN 'asr' THEN asr_errors WHEN 'incorrect' THEN incorrect_responses WHEN 'repetition' THEN repetition_by_bot WHEN 'interrupt' THEN interruption_handling_error WHEN 'hallucination' THEN hallucination_error END) > 0
AND
(CASE t2.err WHEN 'asr' THEN asr_errors WHEN 'incorrect' THEN incorrect_responses WHEN 'repetition' THEN repetition_by_bot WHEN 'interrupt' THEN interruption_handling_error WHEN 'hallucination' THEN hallucination_error END) > 0
THEN 1 ELSE 0 END) AS cooccurrence_count
FROM synthetic_calls
CROSS JOIN (SELECT 'asr' AS err UNION SELECT 'incorrect' UNION SELECT 'repetition' UNION SELECT 'interrupt' UNION SELECT 'hallucination') t1
CROSS JOIN (SELECT 'asr' AS err UNION SELECT 'incorrect' UNION SELECT 'repetition' UNION SELECT 'interrupt' UNION SELECT 'hallucination') t2
GROUP BY t1.err, t2.err
ORDER BY cooccurrence_count DESC;

WITH totals AS (
SELECT
call_date,
COUNT(*) AS total_calls,
SUM(CASE WHEN (COALESCE(asr_errors,0)+COALESCE(incorrect_responses,0)+COALESCE(repetition_by_bot,0)+COALESCE(interruption_handling_error,0)+COALESCE(hallucination_error,0)) > 0 THEN 1 ELSE 0 END) AS calls_with_any_error,
SUM(CASE WHEN (COALESCE(hallucination_error,0) > 0 OR COALESCE(incorrect_responses,0) >= 2) THEN 1 ELSE 0 END) AS calls_with_critical_error,
SUM(CASE WHEN (COALESCE(asr_errors,0)+COALESCE(incorrect_responses,0)+COALESCE(repetition_by_bot,0)+COALESCE(interruption_handling_error,0)+COALESCE(hallucination_error,0)) > 2 THEN 1 ELSE 0 END) AS calls_with_more_than_2_errors
FROM synthetic_calls
GROUP BY call_date
)
SELECT
call_date,
total_calls,
calls_with_any_error,
ROUND(calls_with_any_error/total_calls*100,2) AS pct_any_error,
calls_with_critical_error,
ROUND(calls_with_critical_error/total_calls*100,2) AS pct_critical,
calls_with_more_than_2_errors,
ROUND(calls_with_more_than_2_errors/total_calls*100,2) AS pct_more_than_2_errors
FROM totals
ORDER BY call_date;

WITH ordered AS (
SELECT call_duration_sec,
ROW_NUMBER() OVER (ORDER BY call_duration_sec) AS rn,
COUNT(*) OVER () AS total_rows
FROM synthetic_calls
)
SELECT
MAX(CASE WHEN rn = FLOOR(total_rows*0.10) OR rn = CEIL(total_rows*0.10) THEN call_duration_sec END) AS p10,
MAX(CASE WHEN rn = FLOOR(total_rows*0.25) OR rn = CEIL(total_rows*0.25) THEN call_duration_sec END) AS p25,
MAX(CASE WHEN rn = FLOOR(total_rows*0.50) OR rn = CEIL(total_rows*0.50) THEN call_duration_sec END) AS p50,
MAX(CASE WHEN rn = FLOOR(total_rows*0.75) OR rn = CEIL(total_rows*0.75) THEN call_duration_sec END) AS p75,
MAX(CASE WHEN rn = FLOOR(total_rows*0.90) OR rn = CEIL(total_rows*0.90) THEN call_duration_sec END) AS p90,
MAX(CASE WHEN rn = FLOOR(total_rows*0.95) OR rn = CEIL(total_rows*0.95) THEN call_duration_sec END) AS p95,
MAX(CASE WHEN rn = FLOOR(total_rows*0.99) OR rn = CEIL(total_rows*0.99) THEN call_duration_sec END) AS p99
FROM ordered;

WITH per_day AS (
SELECT
call_date,
call_duration_sec,
ROW_NUMBER() OVER (PARTITION BY call_date ORDER BY call_duration_sec) AS rn,
COUNT(*) OVER (PARTITION BY call_date) AS total_rows
FROM synthetic_calls
)
SELECT
call_date,
MAX(CASE WHEN rn = FLOOR(total_rows*0.50) OR rn = CEIL(total_rows*0.50) THEN call_duration_sec END) AS p50,
MAX(CASE WHEN rn = FLOOR(total_rows*0.90) OR rn = CEIL(total_rows*0.90) THEN call_duration_sec END) AS p90
FROM per_day
GROUP BY call_date
ORDER BY call_date;

SELECT error_type, calls_affected, ROUND(avg_duration_sec,2) AS avg_duration_sec, ROUND(avg_total_errors,3) AS avg_total_errors
FROM (
SELECT 'asr_errors' AS error_type, COUNT(*) AS calls_affected, AVG(call_duration_sec) AS avg_duration_sec, AVG((COALESCE(asr_errors,0)+COALESCE(incorrect_responses,0)+COALESCE(repetition_by_bot,0)+COALESCE(interruption_handling_error,0)+COALESCE(hallucination_error,0))) AS avg_total_errors FROM synthetic_calls WHERE COALESCE(asr_errors,0) > 0
UNION ALL
SELECT 'incorrect_responses', COUNT(*), AVG(call_duration_sec), AVG((COALESCE(asr_errors,0)+COALESCE(incorrect_responses,0)+COALESCE(repetition_by_bot,0)+COALESCE(interruption_handling_error,0)+COALESCE(hallucination_error,0))) FROM synthetic_calls WHERE COALESCE(incorrect_responses,0) > 0
UNION ALL
SELECT 'repetition_by_bot', COUNT(*), AVG(call_duration_sec), AVG((COALESCE(asr_errors,0)+COALESCE(incorrect_responses,0)+COALESCE(repetition_by_bot,0)+COALESCE(interruption_handling_error,0)+COALESCE(hallucination_error,0))) FROM synthetic_calls WHERE COALESCE(repetition_by_bot,0) > 0
UNION ALL
SELECT 'interruption_handling_error', COUNT(*), AVG(call_duration_sec), AVG((COALESCE(asr_errors,0)+COALESCE(incorrect_responses,0)+COALESCE(repetition_by_bot,0)+COALESCE(interruption_handling_error,0)+COALESCE(hallucination_error,0))) FROM synthetic_calls WHERE COALESCE(interruption_handling_error,0) > 0
UNION ALL
SELECT 'hallucination_error', COUNT(*), AVG(call_duration_sec), AVG((COALESCE(asr_errors,0)+COALESCE(incorrect_responses,0)+COALESCE(repetition_by_bot,0)+COALESCE(interruption_handling_error,0)+COALESCE(hallucination_error,0))) FROM synthetic_calls WHERE COALESCE(hallucination_error,0) > 0
) t
ORDER BY calls_affected DESC;

SET @w_hallucination = 5; SET @w_incorrect = 4; SET @w_asr = 3; SET @w_repetition = 2; SET @w_interrupt = 1;
SELECT
callsid,
call_date,
call_duration_sec,
asr_errors,
incorrect_responses,
repetition_by_bot,
interruption_handling_error,
hallucination_error,
(COALESCE(hallucination_error,0)*@w_hallucination
+ COALESCE(incorrect_responses,0)*@w_incorrect
+ COALESCE(asr_errors,0)*@w_asr
+ COALESCE(repetition_by_bot,0)*@w_repetition
+ COALESCE(interruption_handling_error,0)*@w_interrupt) AS risk_score_v2,
CASE WHEN (COALESCE(hallucination_error,0)*@w_hallucination
+ COALESCE(incorrect_responses,0)*@w_incorrect
+ COALESCE(asr_errors,0)*@w_asr
+ COALESCE(repetition_by_bot,0)*@w_repetition
+ COALESCE(interruption_handling_error,0)*@w_interrupt) >= 15 THEN 'High'
WHEN (COALESCE(hallucination_error,0)*@w_hallucination
+ COALESCE(incorrect_responses,0)*@w_incorrect
+ COALESCE(asr_errors,0)*@w_asr
+ COALESCE(repetition_by_bot,0)*@w_repetition
+ COALESCE(interruption_handling_error,0)*@w_interrupt) >= 6 THEN 'Medium'
ELSE 'Low' END AS risk_category
FROM synthetic_calls
ORDER BY risk_score_v2 DESC;