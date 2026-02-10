-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.checkin_center,
    cc.name AS center_name,
    TO_CHAR(longtodate(c.CHECKIN_TIME), 'DD-MM-YYYY') AS checkin_date,
    COUNT(CASE WHEN c.origin = 1 THEN 1 END) AS membercard_count,
    COUNT(CASE WHEN c.origin = 4 THEN 1 END) AS qr_count,
    COUNT(CASE WHEN c.origin NOT IN (1, 4) THEN 1 END) AS undefined_count,
    COUNT(*) AS total_checkins,
    ROUND(
        (COUNT(CASE WHEN c.origin = 4 THEN 1 END) * 100.0) / COUNT(*), 2
    ) AS qr_percentage
FROM checkins c
JOIN centers cc ON cc.id = c.checkin_center
JOIN persons p ON c.person_center = p.center AND c.person_id = p.id
WHERE 
    c.CHECKIN_CENTER IN (:CENTER)
    AND c.CHECKIN_TIME >= (:CHECKIN_TIME_FROM)
    AND c.CHECKIN_TIME <= (:CHECKIN_TIME_TO)
GROUP BY 
    c.checkin_center, 
    cc.name, 
    TO_CHAR(longtodate(c.CHECKIN_TIME), 'DD-MM-YYYY')
ORDER BY 
    c.checkin_center, 
    checkin_date;
