-- The extract is extracted from Exerp on 2026-02-08
-- Extract used to Find the ID of Semesters
SELECT id, name AS "Name", start_date AS "Start Date", end_date AS "End Date"
FROM chelseapiers.semesters
WHERE name IS NOT NULL