-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    ag.id AS "Activity Group ID",
    ag.name AS "Activity Group Name",
    ag.description AS "Description",
    ag.state AS "State"
FROM activity_group ag
ORDER BY ag.name;
