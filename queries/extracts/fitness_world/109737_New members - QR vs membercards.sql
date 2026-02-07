-- This is the version from 2026-02-05
--  
WITH params AS MATERIALIZED (
    SELECT
        TO_TIMESTAMP(:start_dato, 'YYYY-MM-DD HH24:MI:SS') AS fromdate,
        TO_TIMESTAMP(:slut_dato, 'YYYY-MM-DD HH24:MI:SS') AS todate,  -- Added todate
        cen.id AS centerid,
        cen.name AS centername
    FROM
        centers cen
)

SELECT
    c.CHECKIN_CENTER AS CenterID,
    params.centername AS CenterNavn,
    to_char(TO_TIMESTAMP(c.checkin_time), 'DD-MM-YYYY') AS Dato,
    count(c.CHECKIN_CENTER) AS Antal
FROM
    fw.checkins c
JOIN
    params
ON
    c.checkin_center = params.centerid
WHERE 
    c.CHECKIN_CENTER IN (:scope)
    AND c.checkin_time BETWEEN params.fromdate AND params.todate  -- Corrected date range
GROUP BY
    c.CHECKIN_CENTER,
    params.centername,
    to_char(TO_TIMESTAMP(c.checkin_time), 'DD-MM-YYYY')  -- Added column to GROUP BY
ORDER BY
    c.CHECKIN_CENTER;
