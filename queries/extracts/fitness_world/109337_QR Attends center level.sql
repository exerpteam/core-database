-- This is the version from 2026-02-05
--  
SELECT
    cc.id AS "Center ID",
    cc.name AS "Center Name",
    TO_CHAR(longtodate(att.START_TIME), 'DD-MM-YYYY') AS "Attendance Date",
    COUNT(CASE WHEN att.origin = 4 AND p.persontype = 2 THEN 1 END) AS "QR Staff",
    COUNT(CASE WHEN att.origin = 4 AND p.persontype = 0 THEN 1 END) AS "QR Private",
    COUNT(CASE WHEN att.origin = 4 THEN 1 END) AS "QR Total",
    COUNT(CASE WHEN att.origin = 1 THEN 1 END) AS "Membercard",
    COUNT(*) AS "Total Attendances",
    ROUND(
        (COUNT(CASE WHEN att.origin = 4 AND p.persontype = 2 THEN 1 END) * 100.0) / NULLIF(COUNT(*), 0), 2
    ) AS "QR Staff %",
    ROUND(
        (COUNT(CASE WHEN att.origin = 4 AND p.persontype = 0 THEN 1 END) * 100.0) / NULLIF(COUNT(*), 0), 2
    ) AS "QR Private %",
    ROUND(
        (COUNT(CASE WHEN att.origin = 1 THEN 1 END) * 100.0) / NULLIF(COUNT(*), 0), 2
    ) AS "Membercard %"
FROM attends att
JOIN centers cc ON cc.id = att.person_center
JOIN persons p ON att.person_center = p.center AND att.person_id = p.id
WHERE 
    att.PERSON_CENTER IN (:CENTER)
    AND att.START_TIME >= (:START_TIME_FROM)
    AND att.START_TIME <= (:START_TIME_TO)
GROUP BY 
    cc.id, cc.name, TO_CHAR(longtodate(att.START_TIME), 'DD-MM-YYYY')
ORDER BY 
    "Center ID", "Attendance Date";
