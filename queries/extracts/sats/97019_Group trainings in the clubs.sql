WITH
    all_centers AS Materialized
    (
        SELECT
            ID                                                  AS Club_ID,
            shortname                                           AS CLUB_NAME,
            CAST (dateToLongC(getcentertime(id), id) AS BIGINT) AS FROM_TODAY,
            CAST (dateToLongC(getcentertime(id), id) AS BIGINT)  + $$In_next_days$$*24*3600*1000::BIGINT AS IN_NEXT_X_DAYS
        FROM
            centers
    )
SELECT
    c.Club_ID,
    c.Club_Name,
    COUNT(*) AS "Number of classes in the selected period"
FROM
    BOOKINGS b
JOIN
    all_centers c
ON
    c.club_ID = b.CENTER
JOIN
    ACTIVITY a
ON
    a.ID = b.ACTIVITY
WHERE
    a.activity_type = 2 -- class
AND b.state = 'ACTIVE'
AND b.starttime >= c.from_today
AND b.starttime < c.IN_NEXT_X_DAYS
GROUP BY
    c.club_id,
    c.club_name
ORDER BY
    1