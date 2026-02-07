SELECT
    cp.EXTERNAL_ID                                                                                                     PERSON_ID,
    DECODE(STATEID,0,'notApplicable',1,'nonMember',2,'member',3,'secondaryMember',4,'extra',5,'exMember','UNKNOWN') AS STATEID,
    dms.CHANGE_DATE
FROM
    PUREGYM.DAILY_MEMBER_STATUS_CHANGES dms
JOIN
    PUREGYM.STATE_CHANGE_LOG scl
ON
    scl.ENTRY_TYPE = 5
    AND scl.CENTER = dms.PERSON_CENTER
    AND scl.id = dms.PERSON_ID
JOIN
    PUREGYM.PERSONS p
ON
    p.center = scl.CENTER
    AND p.id = scl.id
JOIN
    PERSONS cp
ON
    cp.CENTER = p.CURRENT_PERSON_CENTER
    AND cp.id = p.CURRENT_PERSON_ID
WHERE
    dms.CHANGE <> 7 --Transfer out
    AND dms.ENTRY_STOP_TIME IS NULL
    AND TRUNC(exerpro.longtodateTZ(scl.ENTRY_START_TIME,'Europe/London')) = TRUNC(exerpro.longtodateTZ(dms.ENTRY_START_TIME,'Europe/London'))
    AND (
        scl.ENTRY_END_TIME >=exerpro.datetolongTZ(TO_CHAR(TRUNC(exerpro.longtodateTZ(scl.ENTRY_START_TIME,'Europe/London')+1),'YYYY-MM-dd HH24:MI'),'Europe/London')
        OR scl.ENTRY_END_TIME IS NULL)
    AND dms.ENTRY_START_TIME > exerpro.datetolongTZ(TO_CHAR(TRUNC(SYSDATE-5),'yyyy-MM-dd HH24:MI'),'Europe/London')