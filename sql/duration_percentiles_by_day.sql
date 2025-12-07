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