-- This is the version from 2026-02-05
--  
SELECT
    cc.id AS "Center ID",
    cc.name AS "Center Name",
    TO_CHAR(longtodate(c.CHECKIN_TIME), 'DD-MM-YYYY') AS "Checkin Date",
    p.CENTER ||'p'|| p.ID as MemberID,
    TO_CHAR(longtodate(c.CHECKIN_TIME), 'HH24:MI:SS') AS "Checkin Time",
    CASE 
        WHEN c.origin = 1 THEN 'membercard'
        WHEN c.origin = 4 THEN 'QR'
        ELSE 'Other' -- Optional for other values
    END AS "Origin",
    c.checkin_center AS "Checkin Center"
FROM checkins c
JOIN centers cc ON cc.id = c.checkin_center
JOIN persons p ON c.person_center = p.center AND c.person_id = p.id
WHERE 
    c.CHECKIN_CENTER IN (:CENTER)
    AND c.CHECKIN_TIME >= (:CHECKIN_TIME_FROM)
    AND c.CHECKIN_TIME <= (:CHECKIN_TIME_TO)
ORDER BY 
    "Center ID", "Checkin Date", "Checkin Time";
