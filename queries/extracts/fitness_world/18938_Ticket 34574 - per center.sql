-- This is the version from 2026-02-05
--  
SELECT
    COUNT(CENTER),
    train_center
FROM
    (
        SELECT DISTINCT
            p.CENTER,
            p.ID,
            CASE
                WHEN c.CHECKIN_CENTER IN(:center)
                THEN 'HOME_CENTER'
                WHEN c.ID IS NULL
                THEN 'NO_CHECKIN'
                ELSE TO_CHAR(c.CHECKIN_CENTER,'999')
            END AS train_center
        FROM
            FW.PERSONS p
        LEFT JOIN FW.CHECKINS c
        ON
            c.PERSON_CENTER = p.CENTER
            AND c.PERSON_ID = p.ID
            AND
            (
                (
                    c.CHECKIN_TIME BETWEEN :fromDate AND :toDate
                )
                OR c.ID IS NULL
            )
        WHERE
            p.CENTER IN (:center)

            AND EXISTS
            (
                SELECT
                    *
                FROM
                    FW.STATE_CHANGE_LOG scl
                WHERE
                    scl.CENTER = p.CENTER
                    AND scl.ID = p.ID
                    AND scl.ENTRY_TYPE = 1
                    AND scl.STATEID = 1
                    AND
                    (
                        scl.ENTRY_START_TIME <= :toDate
                        AND
                        (
                            scl.ENTRY_END_TIME IS NULL
                            OR scl.ENTRY_END_TIME >= :fromDate
                        )
                    )
            )
        ORDER BY
            p.CENTER,
            p.ID
    )
GROUP BY
    train_center