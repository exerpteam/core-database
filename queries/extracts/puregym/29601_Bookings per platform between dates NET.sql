SELECT
    par.booking_center CENTER,
    centers.name CENTER_NAME,
    TO_CHAR(longToDateTZ(par.CREATION_TIME, 'Europe/London'),'YYYY-MM-DD HH24'),
    DECODE( par.USER_INTERFACE_TYPE, 0,'OTHER', 1,'CLIENT',2,'WEB',3,'KIOSK',4,'SCRIPT',5,'API',6,'MOBILE_API','UNKNOWN') AS USER_INTERFACE_TYPE,
    COUNT(1)
FROM PARTICIPATIONS par
JOIN CENTERS
  ON centers.id = par.booking_center
WHERE
    par.booking_center IN ($$scope$$)
    AND par.CREATION_TIME >= $$datefrom$$
    AND par.CREATION_TIME < $$dateto$$ + (3600*1000*24-1)
    AND par.state != 'CANCELLED'
GROUP BY
    par.booking_center,
    centers.name,
    TO_CHAR(longToDateTZ(par.CREATION_TIME, 'Europe/London'),'YYYY-MM-DD HH24'),
    par.USER_INTERFACE_TYPE
ORDER BY
    1, 3 ASC