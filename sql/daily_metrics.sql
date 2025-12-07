use ai_call_quality;
WITH
base AS (
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
ORDER BY call_date