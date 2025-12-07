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