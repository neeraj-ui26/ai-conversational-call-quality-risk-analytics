SELECT 'asr_errors' AS error_type, SUM(asr_errors) AS total_count, ROUND(AVG(asr_errors),6) AS avg_per_call FROM synthetic_calls
UNION ALL
SELECT 'incorrect_responses', SUM(incorrect_responses), ROUND(AVG(incorrect_responses),6) FROM synthetic_calls
UNION ALL
SELECT 'repetition_by_bot', SUM(repetition_by_bot), ROUND(AVG(repetition_by_bot),6) FROM synthetic_calls
UNION ALL
SELECT 'interruption_handling_error', SUM(interruption_handling_error), ROUND(AVG(interruption_handling_error),6) FROM synthetic_calls
UNION ALL
SELECT 'hallucination_error', SUM(hallucination_error), ROUND(AVG(hallucination_error),6) FROM synthetic_calls;