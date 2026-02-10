-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS
    (
        SELECT
           c.id, 
           CAST(datetolong(TO_CHAR(TO_DATE(($$fromdate$$), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT) AS fromDateLong,
           CAST(datetolong(TO_CHAR(TO_DATE(($$todate$$), 'YYYY-MM-DD')+ interval '1 day', 'YYYY-MM-DD')) AS BIGINT) AS toDateLong
                                
        FROM
            centers c
          where c.id in (:scope)
    )
SELECT DISTINCT
    c.name                                                             AS "Center",
    a.NAME                                                             AS "Regional Manager",
    p.FULLNAME                                                         AS "Member Name",
    p.center||'p'||p.id                                                AS "Member ID",
    act.NAME                                                            AS "Event Booked",
    to_char(longtodatetz(bo.STARTTIME,'Europe/London'),'YYYY-MM-DD')   AS "Class Date",
    to_char(longtodatetz(bo.STARTTIME,'Europe/London'),'HH24:MI')      AS "Class Time",
    to_char(longtodatetz(pa.SHOWUP_TIME,'Europe/London'),'YYYY-MM-DD')  AS "Showup Date ",
    to_char(longtodatetz(pa.SHOWUP_TIME,'Europe/London'),'HH24:MI')    AS "Showup Time ",
    emp2.FULLNAME                                                      AS "Staff Name",
    pa.SHOWUP_BY_CENTER ||'p'|| pa.SHOWUP_BY_ID                        AS "Staff ID",
    case when ch.CHECKIN_CENTER is NULL
    then 'No'
    else 'Yes' end                                                     AS "attended that date",
    p.SEX                                                              AS "GENDER",
    ema.TXTVALUE                                                       AS "EMAIL",
    p.LAST_ACTIVE_START_DATE                                           AS "Join date",
   floor(months_between(current_date, p.BIRTHDATE) / 12)                   AS "Age"
FROM
        PARTICIPATIONS pa
JOIN params
on params.id = pa.center        
        
JOIN
    BOOKINGS bo
ON
    pa.BOOKING_CENTER = bo.CENTER
    AND pa.BOOKING_ID = bo.ID
    AND bo.STARTTIME >= PARAMS.fromdatelong
    AND bo.STARTTIME < (PARAMS.todatelong + 86400000)
JOIN
    ACTIVITY act
ON
    act.ID = bo.ACTIVITY
    AND act.ACTIVITY_GROUP_ID IN (1,202,203)
JOIN
    PERSONS p
ON
    pa.PARTICIPANT_CENTER = p.CENTER
    AND pa.PARTICIPANT_ID = p.ID
LEFT JOIN
    PERSONS emp2
ON
    emp2.CENTER = pa.SHOWUP_BY_CENTER
    AND pa.SHOWUP_BY_ID = emp2.ID
LEFT JOIN
    CENTERS c
ON
    c.ID = bo.CENTER
JOIN
    AREA_CENTERS AC
ON
    c.ID = AC.CENTER
JOIN
    AREAS A
ON
    A.ID = AC.AREA
    AND A.PARENT = 61
LEFT JOIN
    CHECKINS ch
ON
    ch.PERSON_CENTER = p.CENTER
    AND ch.PERSON_ID = p.id
    AND ch.CHECKIN_TIME BETWEEN TRUNC(bo.STARTTIME) AND TRUNC(bo.STARTTIME)+1000*60*60*24
LEFT JOIN
    PERSON_EXT_ATTRS ema
ON
    ema.PERSONCENTER = p.CENTER 
    AND ema.PERSONID = p.id
    AND ema.NAME = '_eClub_Email'
WHERE
    pa.SHOWUP_INTERFACE_TYPE = 1
    AND pa.STATE = 'PARTICIPATION'