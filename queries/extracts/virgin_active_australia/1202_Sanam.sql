-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
ac.name
,bo.center||'book'||bo.id
,TO_CHAR(longtodateTZ(bo.STARTTIME, 'Australia/Sydney'), 'DD-MM-YYYY')          AS "Class start date",
    TO_CHAR(longtodateTZ(bo.STARTTIME, 'Australia/Sydney'), 'HH24:MI')             AS "Class start time"
    ,p.external_id,par.STATE,par.USER_INTERFACE_TYPE
FROM
BOOKINGS bo

JOIN
ACTIVITY ac
ON
ac.ID = bo.ACTIVITY
JOIN
PARTICIPATIONS par
ON bo.CENTER = par.BOOKING_CENTER
    AND bo.ID = par.BOOKING_ID
JOIN PERSONS p
    ON p.CENTER = par.PARTICIPANT_CENTER
    AND p.ID = par.PARTICIPANT_ID
where bo.center = 2004