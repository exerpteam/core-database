WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$Sales_date_from$$                                                   AS salesdatefrom,
            $$Sales_date_to$$                                                   AS salesdateto,
            datetolongC(TO_CHAR($$Sales_date_from$$, 'YYYY-MM-dd HH24:MI' ), 100) AS salesdatefromlong,
            datetolongC(TO_CHAR($$Sales_date_to$$, 'YYYY-MM-dd HH24:MI' ), 100) AS salesdatetolong
        FROM
            dual
    )
SELECT DISTINCT
    sub.owner_center                                                     AS ClubId,
    club.NAME                                                            AS ClubName,
    TO_CHAR(longtodatec(inv.TRANS_TIME, inv.center), 'YYYY-MM-DD HH24:MI') AS SalesDate,
    sales.OWNER_CENTER || 'p' || sales.OWNER_ID                          AS MemberId,
    'Subscription'                                                       AS ProductType,
    PE.center || 'p' || PE.id                                            AS SalesEmployeeId,
    pe.fullname                                                          AS SalesEmployee,
    pd.name                                                              AS ProductName
FROM
    SUBSCRIPTION_SALES sales
CROSS JOIN
    params
JOIN
    centers club
ON
    club.id = sales.owner_center
JOIN
    EMPLOYEES emp
ON
    sales.EMPLOYEE_CENTER=emp.CENTER
    AND sales.EMPLOYEE_ID=emp.ID
JOIN
    PERSONS PE
ON
    emp.PERSONCENTER=PE.CENTER
    AND emp.PERSONID=PE.ID
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
WHERE
    sales.owner_center IN ($$Scope$$)
    AND sales.sales_date >= params.salesdatefrom
    AND sales.sales_date <= params.salesdateto
    AND pd.ptype IN (10)
UNION
SELECT DISTINCT
    CI.id                                                              AS ClubId,
    CI.NAME                                                            AS ClubName,
    TO_CHAR(longtodatec(I.TRANS_TIME, i.center), 'YYYY-MM-DD HH24:MI') AS SalesDate,
    PP.CENTER || 'p' || PP.ID                                          AS MemberId,
    'Clipcard'                                                         AS ProductType,
    PE.CENTER || 'p' || PE.ID                                          AS SalesEmployeeId,
    PE.fullname                                                        AS SalesEmployee,
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
    EMPLOYEES E
ON
    I.EMPLOYEE_CENTER=E.CENTER
    AND I.EMPLOYEE_ID=E.ID
JOIN
    PERSONS PE
ON
    E.PERSONCENTER=PE.CENTER
    AND E.PERSONID=PE.ID
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
WHERE
    P.PTYPE IN (4)
    AND PP.center IN ($$Scope$$)
    AND I.TRANS_TIME>= params.salesdatefromlong
    AND I.TRANS_TIME <= params.salesdatetolong