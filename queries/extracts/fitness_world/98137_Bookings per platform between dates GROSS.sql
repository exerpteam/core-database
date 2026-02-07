-- This is the version from 2026-02-05
--  
SELECT
    par.booking_center AS CENTER,
    centers.name AS CENTER_NAME,
    TO_CHAR(longToDateTZ(par.CREATION_TIME, 'Europe/Copenhagen'), 'YYYY-MM-DD HH24') AS FORMATTED_CREATION_TIME,
    CASE par.USER_INTERFACE_TYPE
        WHEN 0 THEN 'OTHER'
        WHEN 1 THEN 'CLIENT'
        WHEN 2 THEN 'WEB'
        WHEN 3 THEN 'KIOSK'
        WHEN 4 THEN 'SCRIPT'
        WHEN 5 THEN 'API'
        WHEN 6 THEN 'MOBILE_API'
        WHEN 7 THEN 'MOBILE_STAFF'
        ELSE 'UNKNOWN'
    END AS USER_INTERFACE_TYPE,
    COUNT(1)
FROM PARTICIPATIONS par
JOIN CENTERS
  ON centers.id = par.booking_center
WHERE
    par.booking_center IN ($$scope$$)
    AND par.CREATION_TIME >= $$datefrom$$
    AND par.CREATION_TIME < $$dateto$$ + (3600*1000*24-1)
GROUP BY
    par.booking_center,
    centers.name,
    TO_CHAR(longToDateTZ(par.CREATION_TIME, 'Europe/Copenhagen'), 'YYYY-MM-DD HH24'),
    par.USER_INTERFACE_TYPE
ORDER BY
    1, 3 ASC
