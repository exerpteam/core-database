SELECT
    EXTERNAL_ID PERSON_ID,
    CENTER_ID,
    TRUNC(exerpro.longtodate(From_Date)) AS From_Date
FROM
    (
        SELECT
            cp.EXTERNAL_ID,
            p.center as CENTER_ID,
            MIN(scl.BOOK_START_TIME) AS From_Date
        FROM
            PERSONS cp
        JOIN
            PERSONS p
        ON
            cp.CENTER = p.CURRENT_PERSON_CENTER
            AND cp.id = p.CURRENT_PERSON_ID
        JOIN
            STATE_CHANGE_LOG scl
        ON
            scl.center = p.CENTER
            AND scl.id = p.id
            AND scl.ENTRY_TYPE = 1
        WHERE
            NOT EXISTS
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
                    AND scl2.ENTRY_TYPE = 1
                WHERE
                    p2.CURRENT_PERSON_CENTER = cp.center
                    AND p2.CURRENT_PERSON_ID = cp.id
                    AND scl2.ENTRY_TYPE =1
                    AND TRUNC(exerpro.longtodate(scl.BOOK_START_TIME)) = TRUNC(exerpro.longtodate(scl2.BOOK_START_TIME))
                    AND scl2.BOOK_START_TIME > scl.BOOK_START_TIME)
        GROUP BY
            cp.EXTERNAL_ID,
            p.center,
            p.id)
    WHERE
    from_date > exerpro.dateToLong(TO_CHAR(TRUNC(SYSDATE-5), 'YYYY-MM-dd HH24:MI'))
    