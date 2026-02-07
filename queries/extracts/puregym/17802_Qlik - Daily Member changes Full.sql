    SELECT
    cp.EXTERNAL_ID as PERSON_ID,
    dms.PERSON_CENTER                                                                                                                                                  AS Change_center,
    TO_CHAR(dms.CHANGE_DATE,'yyyy-MM-dd')                                                                                                                              AS CHANGE_DATE,
    to_char(longtodate(dms.ENTRY_START_TIME),'HH24:MI') as Change_Time,
DECODE(dms.CHANGE,0,'Other',1,'Joiner',2,'Rejoiner',3,'Reactivated',4,'Leaver',5,'Leaver end of day',6,'Change Membership',7,'Transfer out',8,'Transfer in',9,'Transfer in and change membership',10,'Migrated') AS Change,
    dms.MEMBER_NUMBER_DELTA,
    dms.EXTRA_NUMBER_DELTA,
    dms.SECONDARY_MEMBER_NUMBER_DELTA
FROM
    PUREGYM.DAILY_MEMBER_STATUS_CHANGES dms
JOIN
    PUREGYM.PERSONS p
ON
    p.CENTER = dms.PERSON_CENTER
    AND p.id = dms.PERSON_ID
JOIN
    PUREGYM.PERSONS cp
ON
    cp.center = p.CURRENT_PERSON_CENTER
    AND cp.id = p.CURRENT_PERSON_ID
WHERE
     dms.ENTRY_STOP_TIME IS NULL
    and dms.CHANGE_DATE < sysdate