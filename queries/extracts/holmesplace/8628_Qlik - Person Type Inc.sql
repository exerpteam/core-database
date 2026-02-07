SELECT
    cp.EXTERNAL_ID PERSON_ID,
    DECODE ( scl.STATEID, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE ,
    TO_CHAR(exerpro.longtodatetz(scl.BOOK_START_TIME,'Europe/London'),'yyyy-MM-dd')                                                                            BOOK_START_DATE
FROM
    STATE_CHANGE_LOG scl
JOIN
    PERSONS p
ON
    p.center = scl.center
    AND p.id = scl.id
JOIN
    PERSONS cp
ON
    cp.CENTER = p.CURRENT_PERSON_CENTER
    AND cp.id = p.CURRENT_PERSON_ID
WHERE
    scl.ENTRY_TYPE = 3
    AND scl.ENTRY_START_TIME > exerpro.dateToLong(TO_CHAR(TRUNC(SYSDATE-5), 'YYYY-MM-dd HH24:MI'))
 AND NOT EXISTS
    (
        SELECT
            1
        FROM
            PERSONS p2
        JOIN
            STATE_CHANGE_LOG scl2
        ON
            scl2.center = p2.CENTER
            AND scl2.id = p2.id
            AND scl2.ENTRY_TYPE = 3
        WHERE
            p2.CURRENT_PERSON_CENTER = cp.center
            AND p2.CURRENT_PERSON_ID = cp.id
            AND TRUNC(exerpro.longtodate(scl.BOOK_START_TIME)) = TRUNC(exerpro.longtodate(scl2.BOOK_START_TIME))
            AND scl2.BOOK_START_TIME > scl.BOOK_START_TIME)