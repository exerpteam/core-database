-- The extract is extracted from Exerp on 2026-02-08
-- Estrazione soci attivi, frozen o created con dettaglio sub e addon
WITH
    PARAMS AS MATERIALIZED
    (
        SELECT
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') AS curr_date,
            c.id                                       AS centerID
        FROM
            centers c
    )
SELECT DISTINCT
    s.OWNER_CENTER                   AS CLUB,
    s.OWNER_CENTER||'p'|| s.OWNER_ID AS MEMBER_ID,
    CASE per.persontype
        WHEN 0
        THEN 'Private'
        WHEN 1
        THEN 'Student'
        WHEN 2
        THEN 'Staff'
        WHEN 3
        THEN 'Friend'
        WHEN 4
        THEN 'Corporate'
        WHEN 5
        THEN 'Onemancorporate'
        WHEN 6
        THEN 'Family'
        WHEN 7
        THEN 'Senior'
        WHEN 8
        THEN 'Guest'
        WHEN 9
        THEN 'Child'
        WHEN 10
        THEN 'External_Staff'
        ELSE 'Unknown'
    END    AS PERSON_STATE,
    p.NAME AS SUBSCRIPTION_NAME,
	add_on.main_subscription_key as sub_key,
	s.ID AS SUBSCRIPTION_ID,
    CASE s.state
        WHEN 2
        THEN 'Active'
        WHEN 3
        THEN 'Ended'
        WHEN 4
        THEN 'Frozen'
        WHEN 7
        THEN 'Window'
        WHEN 8
        THEN 'Created'
        ELSE 'Unknown'
    END               AS SUBSCRIPTION_STATE,
    s.START_DATE      AS SUBSCRIPTION_START_DATE,
    add_on.name       AS ADD_ON_NAME,
    add_on.START_DATE AS ADD_ON_START_DATE,
    add_on.END_DATE   AS ADD_ON_END_DATE,
	a.name
    --add_on.pg_name
FROM
    SUBSCRIPTIONS s
JOIN
    CENTERS c
ON
    c.ID = s.OWNER_CENTER
AND c.COUNTRY = 'IT'
JOIN
    SUBSCRIPTIONTYPES st
ON
    st.center = s.SUBSCRIPTIONTYPE_CENTER
AND st.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCTS p
ON
    p.center = st.center
AND p.id = st.id
JOIN
    product_group pg
ON
    pg.id = p.primary_product_group_id
JOIN
    PERSONS per
ON
    per.center = s.OWNER_CENTER
AND per.id = s.OWNER_ID
JOIN
    AREA_CENTERS ac
ON
    ac.center = per.center
JOIN
    areas a
ON
    a.id = ac.area
AND a.ROOT_AREA = 1
LEFT JOIN
    (
        SELECT
            sa.SUBSCRIPTION_CENTER AS center,
            sa.SUBSCRIPTION_ID     AS id,
            sa.START_DATE,
            sa.end_date,
            prod.name,
			sa.SUBSCRIPTION_CENTER ||'ss'|| sa.SUBSCRIPTION_id AS main_subscription_key,
            pgr.name AS pg_name
        FROM
            SUBSCRIPTION_ADDON sa
        JOIN
            params
        ON
            params.centerid = sa.subscription_center
        JOIN
            MASTERPRODUCTREGISTER mpr
        ON
            mpr.id= sa.ADDON_PRODUCT_ID
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = sa.CENTER_ID
        AND prod.GLOBALID = mpr.GLOBALID
        JOIN
            product_and_product_group_link ppgl
        ON
            ppgl.product_center = prod.center
        AND ppgl.product_id = prod.id
        JOIN
            product_group pgr
        ON
            pgr.id = ppgl.product_group_id
        WHERE
			sa.cancelled IS FALSE
		AND
	            (
                sa.end_date IS NULL
            OR  sa.end_date >= params.curr_date) ) add_on
ON
    add_on.center = s.center
AND add_on.id = s.id
WHERE
    -- (
    --        mpr.PRIMARY_PRODUCT_GROUP_ID IN (20005,20004,34802)
    --  OR sa.id IS NULL
    -- )
    -- AND
    s.state IN (2,
                4,
                8) -- ACTIVE, FROZEN, CREATED
AND pg.scope_id = '24'
    --AND (sa.CANCELLED = 'false' OR sa.CANCELLED IS NULL)
    --AND (sa.START_DATE IS NULL OR sa.END_DATE IS NULL OR --CAST(current_date as date) BETWEEN
    -- CAST(sa.START_DATE as date) --AND CAST(sa.END_DATE as date))
AND s.center IN (:scope)