SELECT
    EXTERNAL_ID                                                                                                              PERSON_ID,
    DECODE (MAX(STATEID),0,'notApplicable',1,'nonMember',2,'member',3,'secondaryMember',4,'extra',5,'exMember','UNKNOWN') AS STATEID,
    BOOK_START_TIME                                                                                                       AS CHANGE_DATE
FROM
    (
        SELECT
            cp.EXTERNAL_ID,
            STATEID,
            TO_CHAR(longtodateC(FLOOR(scl.BOOK_START_TIME/1000)*1000,scl.center),'yyyy-MM-dd') BOOK_START_TIME
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
            scl.ENTRY_TYPE = 5
            AND scl.BOOK_START_TIME <dateToLongC(TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-dd HH24:MI'),scl.center)
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
                    AND scl2.ENTRY_TYPE = 5
                WHERE
                    p2.CURRENT_PERSON_CENTER = cp.center
                    AND p2.CURRENT_PERSON_ID = cp.id
                    AND scl2.ENTRY_TYPE =5
                    AND TRUNC(longtodateC(FLOOR(scl.BOOK_START_TIME/1000)*1000,scl.center)) = TRUNC(longtodateC(FLOOR(scl2.BOOK_START_TIME/1000)*1000,scl2.center))
                    AND scl2.ENTRY_START_TIME > scl.ENTRY_START_TIME
                    AND (
                        scl2.STATEID != 0
                        OR scl2.center = scl.center)))
GROUP BY
    EXTERNAL_ID,
    BOOK_START_TIME