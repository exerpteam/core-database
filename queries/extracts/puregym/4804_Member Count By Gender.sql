WITH
    v_excluded_subscriptions AS
    (
        SELECT
            st.center,
            st.id
        FROM
            SUBSCRIPTIONTYPES st
        JOIN
            PRODUCTS pd
        ON
            pd.CENTER = st.CENTER
        AND pd.id = st.id
        JOIN
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        ON
            ppgl.PRODUCT_CENTER = st.center
        AND ppgl.PRODUCT_ID = st.ID
        JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = ppgl.PRODUCT_GROUP_ID
        WHERE
            pg.EXCLUDE_FROM_MEMBER_COUNT = true
    )
SELECT
    CASE
        WHEN C.ID IS NULL
        THEN '-Total'
        ELSE CAST(c.ID AS VARCHAR)
    END    AS CenterID,
    C.name AS Center,
    A.NAME AS "Regional Manager",
    SUM (
        CASE
            WHEN p.sex = 'M'
            THEN 1
            ELSE 0
        END) AS "Males",
    SUM (
        CASE
            WHEN p.sex = 'F'
            THEN 1
            ELSE 0
        END)                   AS "females",
    COUNT(p.center||'p'||p.ID) AS total,
    TO_CHAR((SUM(
        CASE
            WHEN p.sex = 'M'
            THEN 1
            ELSE 0
        END)*1.00 / COUNT(p.center||'p'||p.ID))*100,'FM9990.00' )||'%'AS "%Males",
    TO_CHAR((SUM (
        CASE
            WHEN p.sex = 'F'
            THEN 1
            ELSE 0
        END)*1.00 / COUNT(p.center||'p'||p.ID))*100,'FM9990.00' )||'%'AS "%Females"
FROM
    persons p
JOIN
    (
        SELECT DISTINCT
            p.CENTER,
            p.ID
        FROM
            persons p
        JOIN
            SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.CENTER
        AND s.OWNER_ID = p.ID
        AND s.STATE IN (2,4,8)
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
        AND s.SUBSCRIPTIONTYPE_ID = st.ID
        AND (ST.CENTER, ST.ID) NOT IN
            (
                SELECT
                    center,
                    id
                FROM
                    V_EXCLUDED_SUBSCRIPTIONS) ) p2
ON
    p.CENTER=p2.CENTER
AND p.ID = p2.ID
JOIN
    CENTERS c
ON
    p.CENTER = c.ID
JOIN
    AREA_CENTERS AC
ON
    C.ID = AC.CENTER
JOIN
    AREAS A
ON
    A.ID = AC.AREA
AND A.PARENT = 61
WHERE
    p.center IN ($$scope$$)
AND p.STATUS IN (1,3)
GROUP BY
    grouping sets ( (C.name,C.ID,A.NAME), () )
ORDER BY
    c.NAME