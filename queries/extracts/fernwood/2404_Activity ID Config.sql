-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    id AS "Activity ID",
    name AS "Activity Name",
    duration_list AS "Duration",
    *
FROM activity
ORDER BY id;
