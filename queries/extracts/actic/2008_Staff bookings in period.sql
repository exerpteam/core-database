SELECT
    TO_CHAR(longtodate(bk.STARTTIME), 'DD') DAY,
    TO_CHAR(longtodate(bk.STARTTIME), 'MM') MONTH,
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY') YEAR,
    TO_CHAR(longtodate(bk.STARTTIME), 'HH24:MI') start_time,
    TO_CHAR(longtodate(bk.STOPTIME), 'HH24:MI') end_time,
    bk.STATE bookingState,
    bk.CREATOR_CENTER || 'emp' || bk.CREATOR_ID creator,
    bk.OWNER_CENTER || 'emp' || bk.OWNER_ID owner,
    par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID member_id,
    DECODE (per.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,
    'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSON_TYPE,
    DECODE (per.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,
    'PROSPECT', 7,'SLETTET','UNKNOWN') AS PERSON_STATUS,
    par.STATE participationState,
    par.CANCELATION_REASON,
    act.NAME activityname,
    act.ACTIVITY_TYPE activitytype
FROM
    BOOKINGS bk
JOIN ACTIVITIES_NEW act
ON
    bk.ACTIVITY = act.ID
LEFT JOIN PARTICIPATIONS par
ON
    par.BOOKING_CENTER = bk.CENTER
    AND par.BOOKING_ID = bk.ID
LEFT JOIN PERSONS per
ON
    par.PARTICIPANT_CENTER = per.CENTER
    AND par.PARTICIPANT_ID = per.ID
WHERE
    bk.center IN (:scope)
    AND act.ACTIVITY_TYPE = 4
  AND longtodate(bk.STARTTIME) >= :FromDate
  AND longtodate(bk.STOPTIME) < :ToDate + 1
ORDER BY bk.STARTTIME