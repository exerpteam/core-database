SELECT
    TO_CHAR(longtodateC(b.STARTTIME,b.CENTER),'YYYY-MM-DD') AS "Date",
    b.Name                                                  AS "Name",
    x."Count"                                               AS "Count",
    SUM(
        CASE
            WHEN pa.state = 'PARTICIPATION'
            THEN 1
            ELSE 0
        END )                                               AS "Member Count"
FROM
    BOOKINGS b
JOIN
    PARTICIPATIONS pa
ON
    pa.booking_center = b.center
    AND pa.booking_id = b.id
JOIN
    (
        SELECT
            b2.name,
            TO_CHAR(longtodateC(b2.STARTTIME,b2.CENTER),'YYYY-MM-DD') AS "Date",
            COUNT(*) AS "Count"
        FROM
            bookings b2
        WHERE
            b2.STARTTIME >= $$FROM_DATE$$
        AND b2.STARTTIME <  $$TO_DATE$$ + 86400 * 1000 
        AND b2.STATE='ACTIVE'
        GROUP BY
            b2.name,
            TO_CHAR(longtodateC(b2.STARTTIME,b2.CENTER),'YYYY-MM-DD')
    ) x
ON
    x.name = b.name
    AND x."Date" = TO_CHAR(longtodateC(b.STARTTIME,b.CENTER),'YYYY-MM-DD')
WHERE
    b.CENTER IN ($$scope$$)
    AND b.STARTTIME >= $$FROM_DATE$$
    AND b.STARTTIME < $$TO_DATE$$ + 86400 * 1000
    AND b.STATE='ACTIVE'
GROUP BY
    TO_CHAR(longtodateC(b.STARTTIME,b.CENTER),'YYYY-MM-DD'),
    b.Name,
    x."Count"