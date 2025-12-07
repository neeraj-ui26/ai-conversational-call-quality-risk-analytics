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