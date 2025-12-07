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