SELECT DISTINCT
    pu.id,
    rg.name                             AS "Campaign",
    il.PERSON_CENTER||'p'||il.PERSON_ID AS "MemberID",
    TO_CHAR(s.START_DATE, 'yyyy-MM-dd') AS "Start Date",
    --TO_CHAR(MIN(s.START_DATE) over (partition BY il.PERSON_CENTER, il.PERSON_ID), 'yyyy-MM-dd') AS "Start Date",
    pr.NAME                                                  AS "Product",
    pr.PRICE                                                 AS "Product Price",
    il.TOTAL_AMOUNT                                          AS "Individual Product Price",
    TO_CHAR(longtodateC(pu.USE_TIME,il.center),'yyyy-MM-dd') AS "Date"
FROM
    PRIVILEGE_USAGES pu
LEFT JOIN
    PRIVILEGE_GRANTS pg
ON
    pg.ID = pu.GRANT_ID
JOIN
    PRIVILEGE_RECEIVER_GROUPS rg
ON
    pg.GRANTER_SERVICE = 'ReceiverGroup'
    AND rg.ID = pu.SOURCE_ID
JOIN
    INVOICE_LINES_MT il
ON
    il.center = pu.TARGET_CENTER
    AND il.id = pu.TARGET_ID
    AND il.SUBID = pu.TARGET_SUBID
LEFT JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = il.PERSON_CENTER
    AND s.OWNER_ID = il.PERSON_ID
    AND s.STATE IN (2,
                    4)
LEFT JOIN
    PRODUCTS pr
ON
    pr.center = il.PRODUCTCENTER
    AND pr.id = il.PRODUCTID
WHERE
    pu.TARGET_SERVICE IN ('InvoiceLine')
    AND pg.GRANTER_SERVICE = 'ReceiverGroup'
    AND rg.RGTYPE ='UNLIMITED'
    AND pu.SOURCE_ID = 15008 -- UNLIMITED NO Nutramino Free
    AND pu.USE_TIME BETWEEN $$from_date$$ AND $$to_date$$+1000*60*60*24
    AND pu.TARGET_CENTER IN ($$scope$$)