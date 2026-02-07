WITH
    params AS
    (
        SELECT
            /*+ materialize */
            DECODE($$offset$$,0,0,dateToLongC(TO_CHAR(TRUNC(SYSDATE-$$offset$$), 'YYYY-MM-dd HH24:MI'),100)) AS from_time,
            dateToLong(TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-dd HH24:MI'))                                      AS to_time
        FROM
            dual
    )
SELECT
    PERSON_ID,
    CENTER_ID,
    FROM_DATE
FROM
    (
        SELECT
            EXTERNAL_ID                                                                                                          AS PERSON_ID,
            center                                                                                                               AS CENTER_ID,
            TO_CHAR(longtodateC(BOOK_START_TIME,center),'yyyy-MM-dd')                                                            AS FROM_DATE,
            row_number() over(partition BY external_id,TRUNC(longtodateC(BOOK_START_TIME,center)) ORDER BY BOOK_START_TIME DESC) AS rn
        FROM
            (
                SELECT
                    EXTERNAL_ID ,
                    FIRST_VALUE(center) OVER (PARTITION BY external_id, center, id ORDER BY BOOK_START_TIME)          center,
                    FIRST_VALUE(BOOK_START_TIME) OVER (PARTITION BY external_id, center, id ORDER BY BOOK_START_TIME) BOOK_START_TIME
                FROM
                    (
                        SELECT
                            cp.EXTERNAL_ID,
                            scl.center,
                            scl.id,
                            scl.BOOK_START_TIME BOOK_START_TIME
                        FROM
                            params,
                            PERSONS p
                        JOIN
                            PERSONS cp
                        ON
                            cp.CENTER = p.CURRENT_PERSON_CENTER
                            AND cp.id = p.CURRENT_PERSON_ID
                        JOIN
                            STATE_CHANGE_LOG scl
                        ON
                            scl.center = p.center
                            AND scl.id = p.id
                            AND scl.ENTRY_TYPE =3
                        WHERE
                            SCL.BOOK_START_TIME BETWEEN params.from_time AND params.to_time
                              and scl.center in ($$scope$$)
                           -- AND cp.EXTERNAL_ID = '1362279'
                            AND NOT EXISTS
                            (
                                SELECT
                                    1
                                FROM
                                    STATE_CHANGE_LOG scl2
                                WHERE
                                    scl2.center = scl.center
                                    AND scl2.id = scl.id
                                    AND scl2.ENTRY_TYPE = 3
                                    AND scl2.BOOK_START_TIME<scl.BOOK_START_TIME)
                        ORDER BY
                            EXTERNAL_ID,
                            BOOK_START_TIME)) )
WHERE
    rn = 1