-- The extract is extracted from Exerp on 2026-02-08
-- To use for aspiration test MEW
 WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
				TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-2) AS previousTwoDays,
				TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')) AS today,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID

    )
SELECT
    per.EXTERNAL_ID,
    pea1.TXTVALUE AS CreationDate,
    DECODE (per.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARY INACTIVE', 4,'TRANSFERED',
    5,'DUPLICATE', 6, 'PROSPECT',7,'DELETED',9,'CONTACT',10,'Ano','UNKNOWN' ) AS
    CurrentPersonstatus,
    prod1.name,
    ss1.sales_date,
    cen1.FACILITY_URL,
    cen1.EXTERNAL_ID AS Cost
FROM
    persons per
LEFT JOIN
    PERSON_EXT_ATTRS pea1
ON
    pea1.PERSONCENTER = per.center
AND pea1.PERSONID = per.id
AND pea1.NAME = 'CREATION_DATE'
LEFT JOIN
    SUBSCRIPTION_SALES ss1
ON
    ss1.OWNER_CENTER = per.CENTER
AND ss1.OWNER_ID = per.ID
LEFT JOIN
    PRODUCTS prod1
ON
    prod1.CENTER = ss1.SUBSCRIPTION_TYPE_CENTER
AND prod1.ID = ss1.SUBSCRIPTION_TYPE_ID
LEFT JOIN
    PRODUCT_GROUP pg1
ON
    prod1.PRIMARY_PRODUCT_GROUP_ID = pg1.ID
LEFT JOIN
    CENTERS cen1
ON
    per.CENTER = cen1.ID
WHERE
    per.CENTER IN (:ChosenScope)
AND per.status = 6
UNION ALL
SELECT
    p.EXTERNAL_ID,
    pea2.TXTVALUE AS CreationDate,
    DECODE (P.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARY INACTIVE', 4,'TRANSFERED', 5
    ,'DUPLICATE', 6, 'PROSPECT',7,'DELETED',9,'CONTACT',10,'Ano','UNKNOWN' ) AS CurrentPersonstatus
    ,
    prod.name,
    ss.sales_date,
    cen2.FACILITY_URL,
    cen2.EXTERNAL_ID AS Cost
FROM
    SUBSCRIPTION_SALES ss
JOIN PARAMS params ON params.CenterID = ss.OWNER_CENTER
LEFT JOIN
    PERSONS P
ON
    ss.OWNER_CENTER = p.CENTER
AND ss.OWNER_ID = p.ID
LEFT JOIN
    PRODUCTS prod
ON
    prod.CENTER = ss.SUBSCRIPTION_TYPE_CENTER
AND prod.ID = ss.SUBSCRIPTION_TYPE_ID
LEFT JOIN
    PRODUCT_GROUP pg
ON
    prod.PRIMARY_PRODUCT_GROUP_ID = pg.ID
LEFT JOIN
    PERSON_EXT_ATTRS pea2
ON
    pea2.PERSONCENTER = p.center
AND pea2.PERSONID = p.id
AND pea2.NAME = 'CREATION_DATE'
LEFT JOIN
    CENTERS cen2
ON
    p.CENTER = cen2.ID
WHERE
    SS.OWNER_CENTER IN (:ChosenScope)
AND ss.SALES_DATE BETWEEN params.previousTwoDays AND params.today
AND prod.PRIMARY_PRODUCT_GROUP_ID IN (7,
                                      8,
                                      9,
                                      10,
                                      11,
                                      12,
                                      218,
                                      219,
                                      221,
                                      220)
AND p.PERSONTYPE != 2
AND p.status NOT IN (2,
                     4)