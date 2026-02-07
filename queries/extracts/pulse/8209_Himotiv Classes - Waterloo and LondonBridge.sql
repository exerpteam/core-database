SELECT DISTINCT
    part.center||'pa'||part.ID AS "CLASS_ID",
    p2.center||'p'||p2.id               AS CUSTOMER_ID,
    bk.center                  AS CLASS_CENTER_ID,
    CASE
        WHEN SUBSTR(bk.NAME, -1)=' '
        THEN SUBSTR(bk.NAME,1,LENGTH(bk.NAME)-1)
        ELSE bk.NAME
    END AS CLASS_NAME,
    CASE
        WHEN SUBSTR(agr.NAME, -1)=' '
        THEN SUBSTR(agr.NAME,1,LENGTH(agr.NAME)-1)
        ELSE agr.NAME
    END                                                          AS CLASS_TYPE,
    TO_CHAR(longtodate(part.CREATION_TIME),'yyyy-MM-dd HH24:MM') AS BookedTime,
    TO_CHAR(longtodate(part.START_TIME),'yyyy-MM-dd HH24:MM')    AS StartTime,
    CASE
        WHEN part.STATE = 'PARTICIPATION'
        THEN 'SHOWUP'
        WHEN part.CANCELATION_REASON IN ('USER')
        THEN 'CANCELLED_MEMBER'
        WHEN part.CANCELATION_REASON IN ('NO_SHOW')
        THEN 'NOSHOW'
        WHEN part.CANCELATION_REASON IN ('NO_SEAT')
        THEN 'NOSEAT'
        ELSE 'CANCELLED_CENTER'
    END AS CLASS_STATUS,
    CASE
        WHEN SUBSTR(brg.NAME, -1)=' '
        THEN SUBSTR(brg.NAME,1,LENGTH(brg.NAME)-1)
        ELSE brg.NAME
    END AS CLASS_RESSOURCE_GROUP
FROM
    PULSE.PARTICIPATIONS part
JOIN
    PULSE.BOOKINGS bk
ON
    bk.center = part.BOOKING_CENTER
    AND bk.id = part.BOOKING_ID
JOIN
    PULSE.PERSONS p
ON
    p.center = part.PARTICIPANT_CENTER
    AND p.id = part.PARTICIPANT_ID
JOIN
    PULSE.ACTIVITY act
ON
    bk.ACTIVITY = act.id
JOIN
    PULSE.ACTIVITY_GROUP agr
ON
    act.ACTIVITY_GROUP_ID = agr.ID
JOIN
    PULSE.PERSONS p
JOIN
    PULSE.PERSONS p2
ON
    p2.CENTER = p.CURRENT_PERSON_CENTER
    AND p2.id = p.CURRENT_PERSON_ID
ON
    p.CENTER = part.PARTICIPANT_CENTER
    AND p.ID = part.PARTICIPANT_ID
JOIN
    PULSE.BOOKING_RESOURCE_USAGE bru
ON
    bru.BOOKING_CENTER = bk.CENTER
    AND bru.BOOKING_ID = bk.ID
JOIN
    PULSE.BOOKING_RESOURCE_CONFIGS brc
ON
    brc.BOOKING_RESOURCE_CENTER = bru.BOOKING_RESOURCE_CENTER
    AND brc.BOOKING_RESOURCE_ID = bru.BOOKING_RESOURCE_ID
JOIN
    PULSE.BOOKING_RESOURCE_GROUPS brg
ON
    brg.ID = brc.GROUP_ID
WHERE
    part.state IN ('PARTICIPATION',
                   'CANCELLED')
    AND bk.STARTTIME BETWEEN datetolong(TO_CHAR(TRUNC(SYSDATE -7), 'YYYY-MM-DD HH24:MI')) AND datetolong(TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-DD HH24:MI')) and part.center in (304,310)