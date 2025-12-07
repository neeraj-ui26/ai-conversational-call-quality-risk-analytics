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