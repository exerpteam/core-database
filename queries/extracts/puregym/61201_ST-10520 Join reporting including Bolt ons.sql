-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    s.center              AS "Center ID",
    c.SHORTNAME           AS "Center",
    cp.EXTERNAL_ID        AS "External ID",
    ss.SALES_DATE         AS "Date of purchase",
    pr.name               AS "Subscription name",
    s.center||'ss'|| s.id AS "Subscription ID",
    NVL(FIRST_VALUE(initsp.PRICE) over (partition BY s.center, s.id ORDER BY sp.FROM_DATE ASC),
    s.SUBSCRIPTION_PRICE) AS "Initial period price",
    NVL(FIRST_VALUE(sp.PRICE) over (partition BY s.center, s.id ORDER BY sp.FROM_DATE ASC),
    s.SUBSCRIPTION_PRICE) AS "Normal period price",
    MAX (
        CASE
            WHEN mpr.CACHED_PRODUCTNAME = 'BodyTrack'
            THEN 1
            ELSE 0
        END) over (partition BY s.center, s.id) AS "BodyTrack",
    FIRST_VALUE(
        CASE
            WHEN mpr.CACHED_PRODUCTNAME = 'BodyTrack'
            THEN sa.INDIVIDUAL_PRICE_PER_UNIT
            ELSE NULL
        END) over (partition BY s.center, s.id ORDER BY
    CASE
        WHEN mpr.CACHED_PRODUCTNAME = 'BodyTrack'
        THEN sa.START_DATE
        ELSE NULL
    END ASC) AS "BodyTrack price",
    FIRST_VALUE(
        CASE
            WHEN mpr.CACHED_PRODUCTNAME = 'BodyTrack'
            THEN mpr.CACHED_PRODUCTPRICE
            ELSE NULL
        END) over (partition BY s.center, s.id ORDER BY
    CASE
        WHEN mpr.CACHED_PRODUCTNAME = 'BodyTrack'
        THEN sa.START_DATE
        ELSE NULL
    END ASC) AS "BodyTrack product price",
    MAX(
        CASE
            WHEN mpr.CACHED_PRODUCTNAME = 'Buddy Access'
            THEN 1
            ELSE 0
        END) over (partition BY s.center, s.id) AS "Buddy",
    FIRST_VALUE(
        CASE
            WHEN mpr.CACHED_PRODUCTNAME = 'Buddy Access'
            THEN sa.INDIVIDUAL_PRICE_PER_UNIT
            ELSE NULL
        END) over (partition BY s.center, s.id ORDER BY
    CASE
        WHEN mpr.CACHED_PRODUCTNAME = 'Buddy Access'
        THEN sa.START_DATE
        ELSE NULL
    END ASC) AS "Buddy price",
    FIRST_VALUE(
        CASE
            WHEN mpr.CACHED_PRODUCTNAME = 'Buddy Access'
            THEN mpr.CACHED_PRODUCTPRICE
            ELSE NULL
        END) over (partition BY s.center, s.id ORDER BY
    CASE
        WHEN mpr.CACHED_PRODUCTNAME = 'Buddy Access'
        THEN sa.START_DATE
        ELSE NULL
    END ASC) AS "Buddy product price" ,
    MAX(
        CASE
            WHEN mpr.CACHED_PRODUCTNAME = 'Extended Class Booking'
            THEN 1
            ELSE 0
        END) over (partition BY s.center, s.id) AS "Extended Classes",
    FIRST_VALUE(
        CASE
            WHEN mpr.CACHED_PRODUCTNAME = 'Extended Class Booking'
            THEN sa.INDIVIDUAL_PRICE_PER_UNIT
            ELSE NULL
        END) over (partition BY s.center, s.id ORDER BY
    CASE
        WHEN mpr.CACHED_PRODUCTNAME = 'Extended Class Booking'
        THEN sa.START_DATE
        ELSE NULL
    END ASC) AS "Extended Classes price",
    FIRST_VALUE(
        CASE
            WHEN mpr.CACHED_PRODUCTNAME = 'Extended Class Booking'
            THEN mpr.CACHED_PRODUCTPRICE
            ELSE NULL
        END) over (partition BY s.center, s.id ORDER BY
    CASE
        WHEN mpr.CACHED_PRODUCTNAME = 'Extended Class Booking'
        THEN sa.START_DATE
        ELSE NULL
    END ASC) AS "Extended Classes product price",
    MAX(
        CASE
            WHEN mpr.CACHED_PRODUCTNAME = 'Hydro Sports Massage'
            THEN 1
            ELSE 0
        END) over (partition BY s.center, s.id) AS "Hydro",
    FIRST_VALUE(
        CASE
            WHEN mpr.CACHED_PRODUCTNAME = 'Hydro Sports Massage'
            THEN sa.INDIVIDUAL_PRICE_PER_UNIT
            ELSE NULL
        END) over (partition BY s.center, s.id ORDER BY
    CASE
        WHEN mpr.CACHED_PRODUCTNAME = 'Hydro Sports Massage'
        THEN sa.START_DATE
        ELSE NULL
    END ASC) AS "Hydro price",
    FIRST_VALUE(
        CASE
            WHEN mpr.CACHED_PRODUCTNAME = 'Hydro Sports Massage'
            THEN mpr.CACHED_PRODUCTPRICE
            ELSE NULL
        END) over (partition BY s.center, s.id ORDER BY
    CASE
        WHEN mpr.CACHED_PRODUCTNAME = 'Hydro Sports Massage'
        THEN sa.START_DATE
        ELSE NULL
    END ASC) AS "Hydro product price" ,
    MAX(
        CASE
            WHEN mpr.CACHED_PRODUCTNAME = 'Yanga Water'
            THEN 1
            ELSE 0
        END) over (partition BY s.center, s.id) AS "Yanga",
    FIRST_VALUE(
        CASE
            WHEN mpr.CACHED_PRODUCTNAME = 'Yanga Water'
            THEN sa.INDIVIDUAL_PRICE_PER_UNIT
            ELSE NULL
        END) over (partition BY s.center, s.id ORDER BY
    CASE
        WHEN mpr.CACHED_PRODUCTNAME = 'Yanga Water'
        THEN sa.START_DATE
        ELSE NULL
    END ASC) AS "Yanga price",
    FIRST_VALUE(
        CASE
            WHEN mpr.CACHED_PRODUCTNAME = 'Yanga Water'
            THEN mpr.CACHED_PRODUCTPRICE
            ELSE NULL
        END) over (partition BY s.center, s.id ORDER BY
    CASE
        WHEN mpr.CACHED_PRODUCTNAME = 'Yanga Water'
        THEN sa.START_DATE
        ELSE NULL
    END ASC) AS "Yanga product price",
	staff.CENTER || 'p' || staff.ID AS "SalesPerson"
FROM
    PUREGYM.STATE_CHANGE_LOG scl
JOIN
    subscriptions s
ON
    s.center =scl.center
AND s.id = scl.id
AND s.SUB_STATE != 8
AND scl.ENTRY_TYPE = 2
AND scl.stateid = 8
AND scl.SUB_STATE NOT IN (10,6)
JOIN
    PUREGYM.SUBSCRIPTION_SALES ss
ON
    ss.SUBSCRIPTION_CENTER = s.center
AND ss.SUBSCRIPTION_ID = s.id
JOIN
    PUREGYM.DAILY_MEMBER_STATUS_CHANGES dms
ON
    dms.PERSON_CENTER = s.owner_center
AND dms.PERSON_ID = s.OWNER_ID
AND dms.CHANGE_DATE = ss.SALES_DATE
JOIN
    PUREGYM.PERSONS p1
ON
    p1.center=dms.PERSON_CENTER
AND p1.id = dms.PERSON_ID
JOIN
    PUREGYM.PERSONS cp
ON
    p1.TRANSFERS_CURRENT_PRS_CENTER=cp.center
AND p1.TRANSFERS_CURRENT_PRS_ID = cp.id
JOIN
    PUREGYM.PRODUCTS pr
ON
    pr.center = s.SUBSCRIPTIONTYPE_CENTER
AND pr.id = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    PUREGYM.EMPLOYEES emp
ON
    emp.center = s.CREATOR_CENTER
AND emp.id = s.CREATOR_ID
LEFT JOIN
    PUREGYM.PERSONS staff
ON
    staff.center = emp.PERSONCENTER
AND staff.id = emp.PERSONID
JOIN
    centers c
ON
    c.id = s.center
left JOIN
    PUREGYM.SUBSCRIPTION_ADDON sa
ON
    sa.SUBSCRIPTION_CENTER = s.center
AND sa.SUBSCRIPTION_ID = s.id
LEFT JOIN
    PUREGYM.MASTERPRODUCTREGISTER mpr
ON
    mpr.id = sa.ADDON_PRODUCT_ID
LEFT JOIN
    PUREGYM.SUBSCRIPTION_PRICE sp
ON
    sp.SUBSCRIPTION_CENTER = s.center
AND sp.SUBSCRIPTION_ID = s.id
AND sp.TYPE = 'NORMAL'
LEFT JOIN
    PUREGYM.SUBSCRIPTION_PRICE initsp
ON
    initsp.SUBSCRIPTION_CENTER = s.center
AND initsp.SUBSCRIPTION_ID = s.id
AND initsp.TYPE = 'INITIAL'
WHERE
    dms.MEMBER_NUMBER_DELTA = 1
AND dms.ENTRY_STOP_TIME IS NULL
    --AND p1.external_id = '7639766'
AND dms.CHANGE_DATE BETWEEN $$from_date$$ AND $$to_date$$
AND dms.PERSON_CENTER IN ($$scope$$)