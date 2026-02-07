SELECT
    --c.id,
    c.name Club,
    ss.SALES_DATE,
    ss.START_DATE,
    ss.CANCELLATION_DATE,
    (CASE ss.TYPE
        WHEN 1 THEN 'New'
        WHEN 2 THEN 'Extension'
        WHEN 3 THEN 'Change'
        ELSE 'Unknown'
    END) AS Sales_Type,
    prod.NAME                                                         product_name,
    p.CENTER || 'p' || p.ID                                           Person_ID,
    pg.NAME                                                           Product_Group,
    CASE
        WHEN ss.CANCELLATION_DATE IS NOT NULL
        THEN -1 * COUNT(pg.ID) OVER (PARTITION BY pg.ID)
        ELSE COUNT(pg.ID) OVER (PARTITION BY pg.ID)
    END AS               total_sales_within,
    perCreation.txtvalue "Original_Join_ate",
    oldSystemId.txtvalue "Old_System_Date"
FROM
    SUBSCRIPTION_SALES ss
JOIN
    PERSONS pold
ON
    pold.CENTER = ss.OWNER_CENTER
AND pold.ID = ss.OWNER_ID
JOIN
    PERSONS p
ON
    p.CENTER = pold.CURRENT_PERSON_CENTER
AND p.ID = pold.CURRENT_PERSON_ID
JOIN
    centers c
ON
    c.id = p.center
JOIN
    PRODUCTS prod
ON
    prod.CENTER = ss.SUBSCRIPTION_TYPE_CENTER
AND prod.ID = ss.SUBSCRIPTION_TYPE_ID
JOIN
    PRODUCT_GROUP pg
ON
    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
AND pg.NAME LIKE 'Mem Cat%'
LEFT JOIN
    PERSON_EXT_ATTRS perCreation
ON
    perCreation.PERSONCENTER = p.CENTER
AND perCreation.PERSONID = p.ID
AND perCreation.NAME = 'CREATION_DATE'
LEFT JOIN
    PERSON_EXT_ATTRS oldSystemId
ON
    oldSystemId.PERSONCENTER = p.CENTER
AND oldSystemId.PERSONID = p.ID
AND oldSystemId.NAME = '_eClub_OldSystemPersonId'
WHERE
    --Italian Clubs
    C.COUNTRY = 'IT'
AND
    -- member has not cancelled but was sold this month
    ( (
            ss.CANCELLATION_DATE IS NULL
        AND ss.SALES_DATE >= DATE_TRUNC('month',TO_DATE(getCenterTime(ss.subscription_center),'YYYY-MM-DD')) )
    OR
        -- member has cancelled in this month
        (
            ss.CANCELLATION_DATE IS NOT NULL
        AND ss.CANCELLATION_DATE >= DATE_TRUNC('month',TO_DATE(getCenterTime(ss.subscription_center),'YYYY-MM-DD')) ) )