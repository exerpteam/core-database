-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    bo.NAME,
    bo.CENTER||'book'||bo.ID AS "Class ID"
FROM
    PUREGYM.BOOKINGS bo
    where bo.STARTTIME > datetolong(to_char(add_months(trunc(sysdate),-12), 'YYYY-MM-dd HH24:MI'))
