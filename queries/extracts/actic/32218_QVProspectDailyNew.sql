WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
				datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS fromDate,
                datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) + 86399000 AS toDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )
SELECT
    cen.COUNTRY,
    cen.EXTERNAL_ID             AS Cost,
    per.CENTER || 'p' || per.ID AS PersonId,
    DECODE (per.status, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARY INACTIVE', 4,'TRANSFERED',
    5,'DUPLICATE', 6, 'PROSPECT',7,'DELETED',9,'CONTACT', 'UNKNOWN') AS CURRENT_PERSONSTATUS,
    DECODE (scl_pstatus.STATEID, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARY INACTIVE', 4,
    'TRANSFERED', 5,'DUPLICATE', 6, 'PROSPECT',7,'DELETED',9,'CONTACT', 'UNKNOWN') AS PERSONSTATUS,
    pea_creationdate.TXTVALUE                                                      AS CreationDate,
    TO_CHAR(longToDate(scl_pstatus.ENTRY_START_TIME),'YYYY-MM-DD')                                       AS ProspectDate
FROM
    PERSONS per
JOIN PARAMS params ON params.CenterID = per.CENTER
LEFT JOIN
    CENTERS cen
ON
    per.CENTER = cen.ID
LEFT JOIN
    PERSON_EXT_ATTRS pea_creationdate
ON
    pea_creationdate.PERSONCENTER = per.center
AND pea_creationdate.PERSONID = per.id
AND pea_creationdate.NAME = 'CREATION_DATE'
    -- personstatus at the time choosen
    -- added by MB
LEFT JOIN
    STATE_CHANGE_LOG scl_pstatus
ON
    per.CENTER = scl_pstatus.CENTER
AND per.ID = scl_pstatus.ID
WHERE
    per.center IN (:Scope)
AND scl_pstatus.ENTRY_TYPE = 1
AND scl_pstatus.STATEID = 6
AND scl_pstatus.ENTRY_START_TIME >= params.fromDate
    -- yesterday at midnight
AND scl_pstatus.ENTRY_START_TIME < params.toDate -- yesterday at midnight +24 hours --in ms