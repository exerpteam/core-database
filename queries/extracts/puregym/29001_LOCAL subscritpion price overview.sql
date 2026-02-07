SELECT
    c.name AS "Club name",
    CASE
        WHEN c.STARTUPDATE>SYSDATE
        THEN 'Pre-Join'
        ELSE 'Open'
    END                                  AS "Status",
    a.name                               AS "Regional manager",
    s.name                               AS "Subscription name",
    s.PRICE                              AS "Current live monthly fee (GBP)" ,
    j.PRICE                              AS "Current live joining fee (GBP)",
    TO_CHAR(C.STARTUPDATE, 'dd-mm-yyyy') AS "Opening Day",
    kd.VALUE                             AS "Last Weeks Monthly fee (GBP)",
    kd2.VALUE                            AS "Last Weeks Joining  (GBP)",
    CASE
        WHEN kd.VALUE != s.PRICE
        THEN 'Yes'
        ELSE 'No'
    END AS "Monthly fee changed",
    CASE
        WHEN kd2.VALUE != j.PRICE
        THEN 'Yes'
        ELSE 'No'
    END     AS "Joining fee changed",
    a2.name AS "Price Tier"
FROM
    PUREGYM.SUBSCRIPTIONTYPES st
JOIN
    products s
ON
    s.CENTER = st.CENTER
    AND s.id = st.id
    AND s.EXTERNAL_ID = 'LOCAL' 
JOIN
    products j
ON
    j.center = st.PRODUCTNEW_CENTER
    AND j.id = st.PRODUCTNEW_ID
JOIN
    centers c
ON
    c.id = st.center
JOIN
    AREA_CENTERS AC
ON
    C.ID = AC.CENTER
JOIN
    AREAS A
ON
    A.ID = AC.AREA
    -- Area Managers/UK
    AND A.PARENT = 61
JOIN
    AREA_CENTERS AC2
ON
    C.ID = AC2.CENTER
JOIN
    AREAS A2
ON
    A2.ID = AC2.AREA
    -- price tier
    AND A2.PARENT = 31
JOIN
    (
        SELECT
            mp.CENTER,
            MIN(mp.price) AS price
        FROM
            PUREGYM.PRODUCTS mp
        JOIN
            PUREGYM.SUBSCRIPTIONTYPES st2
        ON
            mp.center = st2.CENTER
            AND mp.id = st2.id
            AND st2.ST_TYPE = 1
        WHERE
            mp.BLOCKED = 0
            AND mp.EXTERNAL_ID = 'LOCAL' 
        GROUP BY
            mp.CENTER) mins
ON
    s.CENTER = mins.center
    AND s.PRICE = mins.price
JOIN
    PUREGYM.KPI_FIELDS kf
ON
    kf.KEY = 'LOWESTPRICE'
LEFT JOIN
    PUREGYM.KPI_DATA kd
ON
    kd.FIELD = kf.ID
    AND kd.CENTER = st.CENTER
    AND kd.FOR_DATE = TRUNC(SYSDATE) - 7
LEFT JOIN
    PUREGYM.KPI_FIELDS kf2
ON
    kf2.KEY = 'LOWESTPRICEJF'
LEFT JOIN
    PUREGYM.KPI_DATA kd2
ON
    kd2.FIELD = kf2.ID
    AND kd2.CENTER = st.CENTER
    AND kd2.FOR_DATE = TRUNC(SYSDATE) - 7
WHERE
    -- DD subscriptions
    st.ST_TYPE = 1
    AND s.BLOCKED = 0
    AND j.blocked = 0
    AND st.center IN ( $$scope$$ )
	AND s.EXTERNAL_ID = 'LOCAL'
ORDER BY
    "Club name",
    "Regional manager",
    "Current live monthly fee (GBP)"