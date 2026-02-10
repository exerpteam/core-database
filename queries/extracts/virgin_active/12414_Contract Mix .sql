-- The extract is extracted from Exerp on 2026-02-08
-- Linked to Contract Mix uk report

SELECT
	c.id,
	c.name center_name,
    ss.SALES_DATE,
    ss.START_DATE,
ss.CANCELLATION_DATE,
decode(ss.TYPE, 1, 'New', 2, 'Extension', 3, 'Change', 'Unknown') sales_type,
    prod.NAME product_name,
    p.CENTER || 'p' || p.ID pid,
   /* a.NAME area,*/
    pg.NAME product_group_name,
    CASE
        WHEN NVL2(ss.CANCELLATION_DATE,1,0) = 1
        THEN -1 * COUNT(pg.ID) OVER (PARTITION BY pg.ID,NVL2(ss.CANCELLATION_DATE,1,0) )
        ELSE COUNT(pg.ID) OVER (PARTITION BY pg.ID,NVL2(ss.CANCELLATION_DATE,1,0) )
    END AS total_sales_within,
perCreation.txtvalue "Original joined date",
oldSystemId.txtvalue "Old System Date"
FROM
    SUBSCRIPTION_SALES ss
JOIN PERSONS pold
ON
    pold.CENTER = ss.OWNER_CENTER
    AND pold.ID = ss.OWNER_ID
JOIN PERSONS p
ON
    p.CENTER = pold.CURRENT_PERSON_CENTER
    AND p.ID = pold.CURRENT_PERSON_ID
join centers c on c.id = p.center
/*
JOIN AREA_CENTERS ac
ON
    ac.CENTER = p.CENTER
JOIN AREAS a
ON
    a.ID = ac.AREA
*/
JOIN PRODUCTS prod
ON
    prod.CENTER = ss.SUBSCRIPTION_TYPE_CENTER
    AND prod.ID = ss.SUBSCRIPTION_TYPE_ID
JOIN PRODUCT_GROUP pg
ON
    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
    AND pg.NAME LIKE 'Mem Cat%'

LEFT JOIN PERSON_EXT_ATTRS perCreation
ON
    perCreation.PERSONCENTER = p.CENTER
    AND perCreation.PERSONID = p.ID
    AND perCreation.NAME = 'CREATION_DATE'
LEFT JOIN PERSON_EXT_ATTRS oldSystemId
ON
    oldSystemId.PERSONCENTER = p.CENTER
    AND oldSystemId.PERSONID = p.ID
    AND oldSystemId.NAME = '_eClub_OldSystemPersonId'    

WHERE
    ss.owner_center IN (:scope)
    AND
    (
        (
            ss.CANCELLATION_DATE IS NULL
            AND ss.SALES_DATE BETWEEN :saleStart AND
            (
                :saleEnd + 1
            )
        )
        OR
        (
            ss.CANCELLATION_DATE IS NOT NULL
            AND ss.CANCELLATION_DATE BETWEEN :saleStart AND
            (
                :saleEnd + 1
            )
        )
    )