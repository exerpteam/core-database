-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT distinct
    p.EXTERNAL_ID                                                                                                                    AS "External ID",
    bo.CENTER||'book'||bo.ID                                                                                                         AS "Class ID booked",
    TO_CHAR(longtodatetz(bo.STARTTIME,'Europe/London'),'yyyy-MM-dd')                                                                 AS "Class Date",
    TO_CHAR(longtodatetz(bo.STARTTIME,'Europe/London'),'HH24:MI')                                                                    AS "Class Time",
    emp.FULLNAME                                                                                                                     AS "Class Instructor",
    c.id                                                                                                                             AS "Center ID",
    c.NAME                                                                                                                           AS "Center Name",
    DECODE( bo.STATE,'CANCELLED','Class cancelled',DECODE(par.STATE,'BOOKED',NULL,'CANCELLED','No','PARTICIPATION','Yes','Unknown')) AS "Show Up",
    DECODE( bo.STATE,'ACTIVE','No','CANCELLED','Yes','Unknown')                                                                      AS "Class cancelled?"
FROM
    PUREGYM.PARTICIPATIONS par
JOIN
    PUREGYM.BOOKINGS bo
ON
    par.BOOKING_CENTER = bo.CENTER
    AND par.BOOKING_ID = bo.ID
JOIN
    PUREGYM.PERSONS p
ON
    par.PARTICIPANT_CENTER = p.CENTER
    AND par.PARTICIPANT_ID = p.ID
LEFT JOIN
    PUREGYM.STAFF_USAGE stu
ON
    stu.BOOKING_CENTER = bo.CENTER
    AND stu.BOOKING_ID = bo.ID
    AND stu.STATE = 'ACTIVE'
LEFT JOIN
    PUREGYM.PERSONS emp
ON
    stu.PERSON_CENTER = emp.CENTER
    AND stu.PERSON_ID = emp.ID
JOIN
    PUREGYM.CENTERS c
ON
    c.id = bo.CENTER
