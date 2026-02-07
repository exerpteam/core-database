SELECT
    /* int */
    s.CENTER Club,
    /* bigint */
    -1 EntityNumber,
    /* varchar(20) */
    p.EXTERNAL_ID ExerpMemberID,
    /* varchar(20) */
    atts.TXTVALUE LegacyMemberID,
    /* DateTime */
    longToDate(scl.BOOK_START_TIME) EffectiveDate,
    /* int */
    s2.CENTER TransferClub,
    /* varchar(20) */
    CASE
        WHEN sclPrev.STATEID = 2
            AND scl.STATEID = 3
            AND scl.SUB_STATE = 6
            AND sclPrev.SUB_STATE NOT IN (6)
        THEN 'Transfer'
        WHEN sclPrev.STATEID IN (4)
            AND scl.STATEID = 2
        THEN 'Restart'
        WHEN sclPrev.STATEID IN (2)
            AND scl.STATEID IN (3,7)
        THEN 'Cancel'
        ELSE 'UNDEFINED'
    END AS RecordType
    /*
    scl.CENTER || 'ss' || scl.ID sid,
    longToDate(scl.BOOK_START_TIME) BOOK_START_TIME,
    'from ' || DECODE (sclPrev.STATEID, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') || ' to ' || DECODE (scl.STATEID, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN')                                                                                                                                                               AS S_STATE,
    'from ' || DECODE (sclPrev.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN') || ' to ' || DECODE (scl.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN') AS S_SUB_STATE
    */
FROM
    SUBSCRIPTIONS s
LEFT JOIN SUBSCRIPTIONS s2
ON
    s2.CENTER = s.TRANSFERRED_CENTER
    AND s2.ID = s.TRANSFERRED_ID
/* Might be that this is not updated after transfer */
LEFT JOIN PERSON_EXT_ATTRS atts
ON
    atts.NAME = '_eClub_OldSystemPersonId'
    AND atts.PERSONCENTER = s.OWNER_CENTER
    AND atts.PERSONID = s.OWNER_ID
JOIN PERSONS oldP
ON
    oldP.CENTER = s.OWNER_CENTER
    AND oldP.ID = s.OWNER_ID
JOIN PERSONS p
ON
    p.CENTER = oldP.CURRENT_PERSON_CENTER
    AND p.ID = oldP.CURRENT_PERSON_ID
JOIN STATE_CHANGE_LOG scl
ON
    scl.CENTER = s.CENTER
    AND scl.ID = s.ID
    AND scl.ENTRY_TYPE = 2
LEFT JOIN STATE_CHANGE_LOG sclPrev
ON
    sclPrev.CENTER = scl.CENTER
    AND sclPrev.ID = scl.ID
    AND sclPrev.BOOK_END_TIME = scl.BOOK_START_TIME
WHERE
    scl.ENTRY_START_TIME BETWEEN dateToLong(TO_CHAR(TRUNC(sysdate-1,'DD'),'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR(TRUNC(sysdate,'DD'),'YYYY-MM-dd HH24:MI'))
    /*scl.ENTRY_START_TIME BETWEEN 1407967200000 AND 1408053600000*/
    AND
    (
        sclPrev.STATEID = 2
        AND scl.STATEID = 3
        AND scl.SUB_STATE = 6
        AND sclPrev.SUB_STATE NOT IN (6)
    )
    OR
    (
        sclPrev.STATEID IN (4)
        AND scl.STATEID = 2
    )
    OR
    (
        sclPrev.STATEID IN (2)
        AND scl.STATEID IN (3,7)
    )