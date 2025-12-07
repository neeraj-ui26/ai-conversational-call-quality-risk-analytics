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