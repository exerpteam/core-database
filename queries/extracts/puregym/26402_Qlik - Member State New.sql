WITH
    params AS
    (
        SELECT
            /*+ materialize */
            DECODE($$offset$$,0,0,dateToLongC(TO_CHAR(TRUNC(SYSDATE-$$offset$$), 'YYYY-MM-dd HH24:MI'),100)) AS from_time,
            dateToLongC(TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-dd HH24:MI'),100)                                   AS to_time
        FROM
            dual
    )
SELECT
    EXTERNAL_ID as                                                                                                      PERSON_ID,
    DECODE (STATEID,0,'notApplicable',1,'nonMember',2,'member',3,'secondaryMember',4,'extra',5,'exMember',6,'legacyMember','UNKNOWN') AS STATEID,
    START_TIME                                                                                                                        AS CHANGE_DATE
FROM
    (
        SELECT
            cp.EXTERNAL_ID,
            STATEID,
            TO_CHAR(longtodateC(FLOOR(
                CASE
                    WHEN STATEID = 5
                    THEN scl.BOOK_START_TIME
                    WHEN stateid = 1
                    THEN scl.BOOK_START_TIME
                    ELSE scl.ENTRY_START_TIME
                END /1000)*1000,scl.center),'yyyy-MM-dd') START_TIME,
            --TO_CHAR(longtodateC(FLOOR(DECODE(STATEID,5,scl.BOOK_START_TIME,1,scl.BOOK_START_TIME,scl.ENTRY_START_TIME)/1000)*1000,scl.center),'yyyy-MM-dd') START_TIME
            CASE
                WHEN STATEID = 5
                THEN scl.BOOK_START_TIME
                WHEN stateid = 1
                THEN scl.BOOK_START_TIME
                ELSE scl.ENTRY_START_TIME
            END
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
            scl.ENTRY_TYPE = 5
            -- AND cp.EXTERNAL_ID = '1460955'
            AND scl.BOOK_START_TIME BETWEEN params.from_time AND params.to_time
            AND scl.center IN ($$scope$$)
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
                    AND TRUNC(longtodateC(FLOOR(
                        CASE
                            WHEN scl.STATEID = 5
                            THEN scl.BOOK_START_TIME
                            WHEN scl.stateid = 1
                            THEN scl.BOOK_START_TIME
                            ELSE scl.ENTRY_START_TIME
                        END /1000)*1000,scl2.center)) = TRUNC(longtodateC(FLOOR(
                        CASE
                            WHEN scl2.STATEID = 5
                            THEN scl2.BOOK_START_TIME
                            WHEN scl2.stateid = 1
                            THEN scl2.BOOK_START_TIME
                            ELSE scl2.ENTRY_START_TIME
                        END /1000)*1000,scl2.center))
                    AND
                    CASE
                        WHEN scl2.STATEID = 5
                        THEN scl2.BOOK_START_TIME
                        WHEN scl2.stateid = 1
                        THEN scl2.BOOK_START_TIME
                        ELSE scl2.ENTRY_START_TIME
                    END >
                    CASE
                        WHEN scl.STATEID = 5
                        THEN scl.BOOK_START_TIME
                        WHEN scl.stateid = 1
                        THEN scl.BOOK_START_TIME
                        ELSE scl.ENTRY_START_TIME
                    END ))