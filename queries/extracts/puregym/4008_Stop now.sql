SELECT
    c.id   AS "Center ID",
    c.NAME AS "Center",
    CASE
        WHEN stops.stopsnum IS NULL
        THEN 0
        ELSE stops.stopsnum
    END AS "number of stops"
FROM
    PUREGYM.CENTERS c
LEFT JOIN
    (
        SELECT
            c.id,
            COUNT(*) AS stopsnum
        FROM
            PUREGYM.PERSONS p
        JOIN
            PUREGYM.SUBSCRIPTIONS s
        ON
            s.OWNER_ID = p.id
            AND s.owner_center = p.center
        JOIN
            PUREGYM.SUBSCRIPTION_CHANGE sc
        ON
            sc.OLD_SUBSCRIPTION_CENTER = s.CENTER
            AND sc.OLD_SUBSCRIPTION_ID = s.ID
            AND TRUNC(longToDateTZ(sc.CHANGE_TIME, 'Europe/London'), 'DDD') - s.END_DATE < 1
            AND s.END_DATE <= TRUNC(longToDateTZ(sc.CHANGE_TIME, 'Europe/London'), 'DDD')
            AND sc.TYPE = 'END_DATE'
            join PUREGYM.SUBSCRIPTIONTYPES st on s.SUBSCRIPTIONTYPE_CENTER = st.CENTER and s.SUBSCRIPTIONTYPE_ID = st.ID and st.ST_TYPE = 1
        LEFT JOIN
            PUREGYM.CENTERS c
        ON
            c.ID = p.CENTER
        WHERE
            p.center IN(:scope)
            AND sc.CHANGE_TIME BETWEEN :startdate AND :enddate + 1000*60*60*24
        GROUP BY
            c.id ,
            c.NAME) stops
ON
    c.id= stops.id
    WHERE
            c.ID IN(:scope)