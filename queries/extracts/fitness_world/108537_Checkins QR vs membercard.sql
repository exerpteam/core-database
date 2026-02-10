-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    TO_CHAR(DATE_TRUNC('week', longtodate(c.CHECKIN_TIME)), 'IYYY-"W"IW') AS "Checkin Week",
    COUNT(CASE WHEN c.origin = 4 AND p.persontype = 2 THEN 1 END) AS "QR Staff",
    COUNT(CASE WHEN c.origin = 4 AND p.persontype = 0 THEN 1 END) AS "QR Private",
    COUNT(CASE WHEN c.origin = 4 THEN 1 END) AS "QR Total",
    COUNT(CASE WHEN c.origin = 1 THEN 1 END) AS "Membercard",
    COUNT(*) AS "Total Checkins",
    ROUND(
        (COUNT(CASE WHEN c.origin = 4 AND p.persontype = 2 THEN 1 END) * 100.0) / NULLIF(COUNT(*), 0), 2
    ) AS "QR Staff %",
    ROUND(
        (COUNT(CASE WHEN c.origin = 4 AND p.persontype = 0 THEN 1 END) * 100.0) / NULLIF(COUNT(*), 0), 2
    ) AS "QR Private %",
    ROUND(
        (COUNT(CASE WHEN c.origin = 1 THEN 1 END) * 100.0) / NULLIF(COUNT(*), 0), 2
    ) AS "Membercard %"
FROM checkins c
JOIN centers cc ON cc.id = c.checkin_center
JOIN persons p ON c.person_center = p.center AND c.person_id = p.id
WHERE 
    c.CHECKIN_CENTER IN (:CENTER)
    AND c.CHECKIN_TIME >= (:CHECKIN_TIME_FROM)
    AND c.CHECKIN_TIME <= (:CHECKIN_TIME_TO)
GROUP BY 
    DATE_TRUNC('week', longtodate(c.CHECKIN_TIME))
ORDER BY 
    DATE_TRUNC('week', longtodate(c.CHECKIN_TIME));
