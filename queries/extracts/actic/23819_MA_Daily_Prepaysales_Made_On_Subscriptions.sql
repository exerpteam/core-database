-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS materialized
    (
        SELECT
		CAST(datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS BIGINT) AS fromDate,
                CAST(datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS BIGINT) + 86399000 AS toDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )
SELECT
    ---------------------------------
    -- Center and sale
    cen.COUNTRY,
    cen.EXTERNAL_ID AS Cost,
    cen.ID          AS CENTERID,
    CASE
        WHEN per.CENTER IS NOT NULL
        THEN per.CENTER || 'p' || per.ID
        ELSE NULL
    END AS PersonID,
    per.fullname,
    pem.txtvalue,
    CASE  per.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 
    'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST'  WHEN 9 THEN 'CONTACT'  ELSE NULL END AS "PERSONTYPE", --
    -- null for anonymous
    CASE  per.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARY INACTIVE'  WHEN 4 THEN 'TRANSFERED'
     WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN  'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 9 THEN 'CONTACT'  ELSE NULL END AS PERSONSTATUS,
    --null for anonymous
    --il.CENTER || 'inv' || il.ID AS InvoiceId,
    --il.SUBID AS Invoiceline,
    TO_CHAR(longToDate(i.TRANS_TIME), 'YYYY-MM-DD HH24:MI') AS Trans_Time,
    --TO_CHAR(longToDate(i.ENTRY_TIME), 'YYYY-MM-DD HH24:MI') AS --Entry_Time,i.CASHREGISTER_CENTER
    -- , -- cashregister of center where the sales is typed
    ---------------------------------
    -- Product
    -- prod.PTYPE AS PRODUCT_TYPE,
    --DECODE (prod.ptype, 1,'RETAIL', 2,'SERVICE', 4,'CLIPCARD', 5,'JOINING FEE', 8,'GIFTCARD', 10,
    -- 'SUBSCRIPTION', 14,'ACCESS') AS ProductType,
    prod.CENTER || 'prod' || prod.ID AS ProductId,
    i.text,
    il.TOTAL_AMOUNT
    ---------------------------------
FROM
    INVOICES i -- receipt with possible multiple lines/product
JOIN PARAMS params ON params.CenterID = i.CENTER
JOIN
    INVOICELINES il -- all lines/product in a receipt
ON
    il.center = i.center
AND il.id = i.id
JOIN
    PRODUCTS prod
ON
    prod.center = il.PRODUCTCENTER
AND prod.id = il.PRODUCTID
LEFT JOIN
    PRODUCT_GROUP pg
ON
    prod.PRIMARY_PRODUCT_GROUP_ID = pg.ID
LEFT JOIN
    (
        SELECT
            pgl.PRODUCT_CENTER,
            pgl.PRODUCT_ID,
            -- LISTAGG(pgl.PRODUCT_GROUP_ID, ' ') WITHIN GROUP (ORDER BY pgl.PRODUCT_GROUP_ID) AS
            -- Group_ID,
            STRING_AGG(pg.NAME, ';' ORDER BY pg.NAME) AS Group_ID
        FROM
            PRODUCT_AND_PRODUCT_GROUP_LINK pgl
        LEFT JOIN
            PRODUCT_GROUP pg
        ON
            pgl.PRODUCT_GROUP_ID = pg.ID
        GROUP BY
            pgl.PRODUCT_CENTER,
            pgl.PRODUCT_ID ) allPG
ON
    prod.CENTER = allPG.PRODUCT_CENTER
AND prod.ID = allPG.PRODUCT_ID
LEFT JOIN
    CLIPCARDTYPES cc
ON
    prod.CENTER = cc.CENTER
AND prod.ID = cc.ID
LEFT JOIN
    PRODUCT_ACCOUNT_CONFIGURATIONS pac
ON
    pac.ID = prod.PRODUCT_ACCOUNT_CONFIG_ID
    -- Income accounts
LEFT JOIN
    accounts ai
ON
    ai.GLOBALID = pac.SALES_ACCOUNT_GLOBALID
AND ai.center = prod.CENTER
LEFT JOIN
    ACCOUNT_VAT_TYPE_GROUP avtg
ON
    avtg.ID = ai.ACCOUNT_VAT_TYPE_GROUP_ID
LEFT JOIN
    ACCOUNT_VAT_TYPE_LINK actl
ON
    actl.ACCOUNT_VAT_TYPE_GROUP_ID = avtg.ID
LEFT JOIN
    VAT_TYPES aiVAT
ON
    aiVAT.center = actl.VAT_TYPE_CENTER
AND aiVAT.id = actl.VAT_TYPE_ID
JOIN
    CENTERS cen
ON
    i.center = cen.id
LEFT JOIN
    PERSONS per
ON
    il.PERSON_CENTER = per.center
AND il.PERSON_ID = per.id
LEFT JOIN
    person_ext_attrs pem
ON
    pem.personcenter = per.center
AND pem.personid = per.id
AND pem.name = '_eClub_Email'
LEFT JOIN
    EMPLOYEES emp
ON
    i.EMPLOYEE_CENTER = emp.CENTER
AND i.EMPLOYEE_ID = emp.ID
LEFT JOIN
    PERSONS emp_person
ON
    emp.PERSONCENTER = emp_person.CENTER
AND emp.PERSONID = emp_person.ID
WHERE
    i.CENTER IN (:Scopes)
AND i.TRANS_TIME >= params.fromDate --
    -- yesterday at midnight
AND i.TRANS_TIME < params.toDate
    -- yesterday at midnight +24 hours in ms
    -- ROUND round to nearest..
    -- AND i.TRANS_TIME >= datetolong(TO_CHAR(ROUND(current_timestamp -2), 'YYYY-MM-DD HH24:MI')) --
    -- yesterday at midnight
    -- AND i.TRANS_TIME < datetolong(TO_CHAR(ROUND(current_timestamp -2), 'YYYY-MM-DD HH24:MI')) + 86399*1000
    -- yesterday at midnight +24 hours in ms
    -- AND i.TRANS_TIME BETWEEN (fromDate) AND (toDate + 3600*1000*24-1) --long date
AND prod.ptype IN (10)
AND i.text LIKE '%Butik%'
