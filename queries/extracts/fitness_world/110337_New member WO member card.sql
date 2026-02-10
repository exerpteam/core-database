-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    TO_CHAR(longtodate(c.CHECKIN_TIME), 'DD-MM-YYYY') AS "Checkin Date",
    COUNT(CASE WHEN c.origin = 4 AND p.persontype = 2 THEN 1 END) AS "QR Staff",
    COUNT(
        CASE 
            WHEN c.origin = 4 AND p.persontype = 0 AND EXISTS (
                SELECT 1
                FROM entityidentifiers e
                WHERE e.ref_center = p.center AND e.ref_id = p.id AND e.entitystatus = 1
            ) 
            THEN 1
        END
    ) AS "QR Private WITH Membercard",
    COUNT(
        CASE 
            WHEN c.origin = 4 AND p.persontype = 0 AND NOT EXISTS (
                SELECT 1
                FROM entityidentifiers e
                WHERE e.ref_center = p.center AND e.ref_id = p.id AND e.entitystatus = 1
            ) 
            THEN 1
        END
    ) AS "QR Private WITHOUT Membercard",
    COUNT(CASE WHEN c.origin = 4 THEN 1 END) AS "QR Total",
    COUNT(CASE WHEN c.origin = 1 THEN 1 END) AS "Membercard",
    COUNT(*) AS "Total Checkins",
    ROUND(
        (COUNT(CASE WHEN c.origin = 4 AND p.persontype = 2 THEN 1 END) * 100.0) / NULLIF(COUNT(*), 0), 2
    ) AS "QR Staff %",
    ROUND(
        (COUNT(
            CASE 
                WHEN c.origin = 4 AND p.persontype = 0 AND NOT EXISTS (
                    SELECT 1
                    FROM entityidentifiers e
                    WHERE e.ref_center = p.center AND e.ref_id = p.id AND e.entitystatus = 1
                ) 
                THEN 1
            END
        ) * 100.0) / NULLIF(COUNT(*), 0), 2
    ) AS "QR Private WITHOUT Membercard %",
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
    TO_CHAR(longtodate(c.CHECKIN_TIME), 'DD-MM-YYYY')
ORDER BY 
    "Checkin Date";
