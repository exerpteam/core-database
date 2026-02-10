-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    eu.id,
    eu.extract_id,
    e.name AS extract_name,
    to_timestamp(eu.time / 1000.0) AS executed_at,
    eu.rows_returned,
    eu.time_used,
    eu.source,
    eu.employee_center,
    eu.employee_id
FROM extract_usage eu
JOIN extract e ON e.id = eu.extract_id
WHERE eu.time BETWEEN EXTRACT(EPOCH FROM timestamp '2025-10-15 09:00:00') * 1000
                  AND EXTRACT(EPOCH FROM timestamp '2025-10-15 09:50:00') * 1000
ORDER BY eu.time DESC;