-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    e.identity,
    CASE e.entitystatus
        WHEN 1 THEN 'OK'
        WHEN 2 THEN 'STOLEN'
        WHEN 3 THEN 'MISSING'
        WHEN 4 THEN 'BLOCKED'
        WHEN 5 THEN 'BROKEN'
        WHEN 6 THEN 'RETURNED'
        WHEN 7 THEN 'EXPIRED'
        WHEN 8 THEN 'DELETED'
        WHEN 9 THEN 'COMPROMISED'
        WHEN 10 THEN 'FORGOTTEN'
        WHEN 11 THEN 'BANNED'
        ELSE 'UNKNOWN'
    END AS kort_status,
    e.ref_center || 'p' || e.ref_id AS memberid,
    TO_CHAR(longtodateC(e.start_time, e.ref_center), 'DD-MM-YYYY') AS startdate
FROM entityidentifiers e
WHERE e.start_time BETWEEN :FROMDATE AND :ENDDATE
GROUP BY
    e.identity,
    e.entitystatus,
    e.ref_center,
    e.ref_id,
    TO_CHAR(longtodateC(e.start_time, e.ref_center), 'DD-MM-YYYY')
ORDER BY
    startdate,
    memberid;
