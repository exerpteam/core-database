-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-3224
https://clublead.atlassian.net/browse/ST-3765
https://clublead.atlassian.net/browse/ES-8586
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$Sales_date_from$$                                                 AS salesdatefrom,
            $$Sales_date_to$$                                                   AS salesdateto,
            datetolongC(TO_CHAR($$Sales_date_from$$, 'YYYY-MM-dd HH24:MI' ), 100) AS salesdatefromlong,
            datetolongC(TO_CHAR($$Sales_date_to$$, 'YYYY-MM-dd HH24:MI' ), 100) + + 24*3600*1000 AS salesdatetolong
        FROM
            dual
    )
SELECT DISTINCT
    club.name                                                              AS "Gym Name",
    pe.center                                                              AS "Gym Number",
    TO_CHAR(longtodatec(inv.TRANS_TIME, inv.center), 'YYYY-MM-DD HH24:MI') AS SalesDate,
    NVL2(sales.cancellation_date, 'Yes', 'No')                             AS Cancelled,
    pe.external_id                                                         AS "External ID",
    pe.center || 'p' || pe.id                                              AS MemberId,
    DECODE(st.st_type, 1, 'Yes', 'No')                                     AS "Member",
    pd.name                                                                AS ProductName
FROM
    SUBSCRIPTION_SALES sales
CROSS JOIN
    params
JOIN
    PERSONS PE
ON
    PE.CENTER = sales.owner_center
    AND PE.ID = sales.owner_id
JOIN
    centers club
ON
    club.id = pe.center
JOIN
    SUBSCRIPTIONS sub
ON
    sales.SUBSCRIPTION_CENTER = sub.CENTER
    AND sales.SUBSCRIPTION_ID = sub.ID
JOIN
    invoicelines ivl
ON
    sub.invoiceline_center = ivl.center
    AND sub.invoiceline_id = ivl.id
    AND sub.invoiceline_subid = ivl.subid
JOIN
    invoices inv
ON
    ivl.center = inv.center
    AND ivl.id = inv.id
JOIN
    SUBSCRIPTIONTYPES st
ON
    st.center = sales.SUBSCRIPTION_TYPE_CENTER
    AND st.id = sales.SUBSCRIPTION_TYPE_ID
JOIN
    products pd
ON
    pd.center = st.center
    AND pd.id = st.id
JOIN 
    PRODUCT_AND_PRODUCT_GROUP_LINK prlink
ON
    pd.CENTER = prlink.PRODUCT_CENTER 
    AND pd.ID = prlink.PRODUCT_ID
WHERE
    pe.center IN ($$Scope$$)
    AND sales.sales_date >= params.salesdatefrom
    AND sales.sales_date <= params.salesdateto
    AND pd.ptype IN (10)
    AND prlink.PRODUCT_GROUP_ID = 8602
    AND sub.state IN ($$SubscriptionState$$)
UNION
SELECT DISTINCT
    CI.NAME                                                            AS "Gym Name",
    CI.Id                                                              AS "Gym Number",
    TO_CHAR(longtodatec(I.TRANS_TIME, i.center), 'YYYY-MM-DD HH24:MI') AS SalesDate,
    NVL2(cnl.center, 'Yes', 'No')                                      AS Cancelled,
    PP.external_id                                                     AS "External ID",
    PP.CENTER || 'p' || PP.ID                                          AS MemberId,
    'Yes'                                                              AS "Member",
    P.NAME                                                             AS ProductName
FROM
    INVOICES I
CROSS JOIN
    params
JOIN
    INVOICELINES IL
ON
    I.CENTER=IL.CENTER
    AND I.ID=IL.ID
JOIN
    PRODUCTS P
ON
    IL.PRODUCTCENTER=P.CENTER
    AND IL.PRODUCTID=P.ID
JOIN 
    PRODUCT_AND_PRODUCT_GROUP_LINK plink
ON
    p.CENTER = plink.PRODUCT_CENTER 
    AND p.ID = plink.PRODUCT_ID
JOIN
    CLIPCARDS C
ON
    IL.CENTER=C.INVOICELINE_CENTER
    AND IL.ID=C.INVOICELINE_ID
    AND IL.SUBID=C.INVOICELINE_SUBID
JOIN
    PERSONS PP
ON
    C.OWNER_CENTER=PP.CENTER
    AND C.OWNER_ID=PP.ID
JOIN
    CENTERS CI
ON
    I.CENTER=CI.ID
LEFT JOIN
    CREDIT_NOTE_LINES cnl
ON
    cnl.invoiceline_center = il.center
    AND cnl.invoiceline_id = il.id
    AND cnl.invoiceline_subid = il.subid
WHERE
    P.PTYPE IN (4)
    AND plink.PRODUCT_GROUP_ID = 8602
    AND PP.center IN ($$Scope$$)
    AND I.TRANS_TIME>= params.salesdatefromlong
    AND I.TRANS_TIME <= params.salesdatetolong 