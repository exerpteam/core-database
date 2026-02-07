WITH
    params AS
    (
        SELECT
            /*+ materialize */
            DECODE($$offset$$,0,0,dateToLongC(TO_CHAR(TRUNC(SYSDATE-$$offset$$), 'YYYY-MM-dd HH24:MI'),100)) AS from_time,
            dateToLong(TO_CHAR(TRUNC(SYSDATE-1), 'YYYY-MM-dd HH24:MI'))                                      AS to_time
        FROM
            dual
    )
SELECT
    cp.EXTERNAL_ID                                                                                                                                             PERSON_ID,
    DECODE ( scl.STATEID, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSON_TYPE ,
    TO_CHAR(longtodateC(scl.BOOK_START_TIME,scl.center),'yyyy-MM-dd')                                                                                          BOOK_START_DATE
FROM
    params,
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
    AND scl.BOOK_START_TIME BETWEEN params.from_time AND params.to_time
    AND scl.center IN($$scope$$)
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
            AND scl2.ENTRY_TYPE =5
            AND TRUNC(longtodateC(scl.BOOK_START_TIME,scl.center)) = TRUNC(longtodateC(scl2.BOOK_START_TIME,scl2.center))
            AND scl2.ENTRY_START_TIME > scl.ENTRY_START_TIME
            AND (
                scl2.STATEID != 0
                OR scl2.center = scl.center))