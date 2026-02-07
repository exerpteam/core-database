SELECT DISTINCT
   p.CENTER || 'p' || p.ID 						AS PersonId,
	DECODE (p.status, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARY INACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6, 'PROSPECT',7,'DELETED',9,'CONTACT', 'UNKNOWN')  AS CURRENT_PERSONSTATUS,
    DECODE (scl.STATEID, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARY INACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6, 'PROSPECT',7,'DELETED',9,'CONTACT', 'UNKNOWN')  AS PERSONSTATUS_CHECKIN

FROM
    CHECKINS ch
JOIN
    PERSONS p
ON
    ch.PERSON_CENTER = p.CENTER
    AND ch.PERSON_ID = p.ID
JOIN
    (
        SELECT
            ch2.ID,
            MAX(scl.ENTRY_START_TIME) ENTRY_START_TIME
        FROM
            STATE_CHANGE_LOG scl
        JOIN
            CHECKINS ch2
        ON
            ch2.PERSON_CENTER = scl.CENTER
            AND ch2.PERSON_ID = scl.ID
            AND ch2.CHECKIN_TIME > scl.ENTRY_START_TIME
        WHERE
            scl.ENTRY_TYPE = 1
        GROUP BY
            scl.center,
            scl.id,
            ch2.ID) Lastest_change
ON
    ch.id = Lastest_change.id
JOIN
    STATE_CHANGE_LOG scl
ON
    scl.CENTER =p.CENTER
    AND scl.ID = p.ID
    AND scl.ENTRY_TYPE = 1
    AND scl.ENTRY_START_TIME = Lastest_change.ENTRY_START_TIME

WHERE
    scl.STATEID = 2
    AND p.PERSONTYPE != 2
    AND p.STATUS = 2
    AND p.center IN (:scope)


 AND ch.CHECKIN_TIME >= datetolong(TO_CHAR(TRUNC(exerpsysdate() -1), 'YYYY-MM-DD HH24:MI')) -- yesterday at midnight
	AND ch.CHECKIN_TIME < datetolong(TO_CHAR(TRUNC(exerpsysdate() -1), 'YYYY-MM-DD HH24:MI')) + 86399*1000 -- yesterday at midnight +24 hours in ms