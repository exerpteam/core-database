WITH
    PARAMS AS
    (
        SELECT
            datetolongTZ(TO_CHAR($$from_Date$$, 'YYYY-MM-dd HH24:MI' ),'Europe/London') fromdate,
            datetolongTZ(TO_CHAR($$to_Date$$, 'YYYY-MM-dd HH24:MI' ),'Europe/London')   todate
        FROM
            dual
    )
SELECT DISTINCT
    c.name                                                             AS "Center",
    a.NAME                                                             AS "Regional Manager",
    p.FULLNAME                                                         AS "Member Name",
    p.center||'p'||p.id                                                AS "Member ID",
    ac.NAME                                                            AS "Event Booked",
    TO_CHAR(longtodatetz(bo.STARTTIME,'Europe/London'),'yyyy-MM-dd')   AS "Class Date",
    TO_CHAR(longtodatetz(bo.STARTTIME,'Europe/London'),'HH24:MI')      AS "Class Time",
    TO_CHAR(longtodatetz(pa.SHOWUP_TIME,'Europe/London'),'yyyy-MM-dd') AS "Showup Date ",
    TO_CHAR(longtodatetz(pa.SHOWUP_TIME,'Europe/London'),'HH24:MI')    AS "Showup Time ",
    emp2.FULLNAME                                                      AS "Staff Name",
    pa.SHOWUP_BY_CENTER ||'p'|| pa.SHOWUP_BY_ID                        AS "Staff ID",
    DECODE(ch.CHECKIN_CENTER,NULL,'No','Yes')                          AS "attended that date",
    p.SEX                                                              AS "GENDER",
    ema.TXTVALUE                                                       AS "EMAIL",
    p.LAST_ACTIVE_START_DATE                                           AS "Join date",
    floor(months_between(SYSDATE, p.BIRTHDATE) / 12)                   AS "Age"
FROM
    PARAMS
CROSS JOIN
    PUREGYM.PARTICIPATIONS pa
JOIN
    PUREGYM.BOOKINGS bo
ON
    pa.BOOKING_CENTER = bo.CENTER
    AND pa.BOOKING_ID = bo.ID
    AND bo.STARTTIME >= PARAMS.fromdate
    AND bo.STARTTIME < (PARAMS.todate + 86400000)
JOIN
    PUREGYM.ACTIVITY ac
ON
    ac.ID = bo.ACTIVITY
    AND ac.ACTIVITY_GROUP_ID IN (1,202,203)
JOIN
    PUREGYM.PERSONS p
ON
    pa.PARTICIPANT_CENTER = p.CENTER
    AND pa.PARTICIPANT_ID = p.ID
LEFT JOIN
    PUREGYM.PERSONS emp2
ON
    emp2.CENTER = pa.SHOWUP_BY_CENTER
    AND pa.SHOWUP_BY_ID = emp2.ID
LEFT JOIN
    PUREGYM.CENTERS c
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
    PUREGYM.CHECKINS ch
ON
    ch.PERSON_CENTER = p.CENTER
    AND ch.PERSON_ID = p.id
    AND ch.CHECKIN_TIME BETWEEN TRUNC(bo.STARTTIME) AND TRUNC(bo.STARTTIME)+1000*60*60*24
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS ema
ON
    ema.PERSONCENTER = p.CENTER
    AND ema.PERSONID = p.id
    AND ema.NAME = '_eClub_Email'
WHERE
    pa.SHOWUP_INTERFACE_TYPE = 1
    AND pa.STATE = 'PARTICIPATION'
    AND AC.ID IN (40,410,1011,41,6002,805,38)