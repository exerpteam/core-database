SELECT
    t.*
FROM
    (
        SELECT
            CEN.STATE,
            CEN.NAME,
            C.NAME,
            (
                CASE
                    WHEN D.NAME IS NULL
                    THEN TRUE
                    WHEN D.NAME = 'lifetimefitnessclubpos'
                    THEN FALSE
                END ) AS MISSING_CLUB_POS,
            (
                CASE
                    WHEN SP.GLOBALID IS NULL
                    THEN TRUE
                    WHEN SP.GLOBALID = 'CLIENT_CASHREGISTER'
                    THEN FALSE
                END ) AS MISSING_CASH_REGISTER
        FROM
            CLIENTS C
        LEFT JOIN
            DEVICES D
        ON
            C.ID = D.CLIENT
        AND D.NAME = 'lifetimefitnessclubpos'
        LEFT JOIN
            SYSTEMPROPERTIES SP
        ON
            SP.CLIENT = C.ID
        AND SP.GLOBALID = 'CLIENT_CASHREGISTER'
        JOIN
            CENTERS CEN
        ON
            C.CENTER = CEN.ID
        WHERE
            C.NAME LIKE '%PCI%'
        ORDER BY
            1,2,3)t