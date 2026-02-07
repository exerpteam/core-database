-- This is the version from 2026-02-05
--  
SELECT DISTINCT
    t1.Addon_center          AS "Subscription Add-on Center ID",
    t1.Addon_name            AS "ADD-ON Name",
    t1.Addon_price           AS "ADD-ON price from product",
    t1.center ||'ss'|| t1.id AS "Subscription Key",
    t1.Sub_name              AS "Main Subscription name",
    t1.Sub_prod              AS "Main Subscription from product",
    t1.BINDING_PRICE,
    longtodate(t1.Addon_creation)   AS "ADD-ON creation date",
    t1.Addon_start                  AS "ADD-ON start date",
    t1.Addon_end                    AS "ADD-ON end date",
    t1.Salesperson_id               AS "Sales person ID",
    t1.Salesperson_name             AS "Sales person name",
    t1.Sub_end                      AS "Main Subscription end date",
    t1.Sub_state                    AS "Main subscription state",
    t1.per_center ||'p'|| t1.per_id AS "Member Id",
    t1.sex,
    CASE  t1.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 
    'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END "main Person type",
    TO_CHAR(t1.START_DATE,'yyyy-MM-dd') AS "subscription start date",
    inv.CENTER AS "Sales center",
    CASE
        WHEN inv.CASHREGISTER_CENTER IS NOT NULL
        THEN inv.CASHREGISTER_CENTER ||'cr'|| inv.CASHREGISTER_ID
        ELSE NULL
    END AS "Cashregister ID"
FROM
    (
        SELECT
            sa.CENTER_ID AS Addon_center ,
            prod.NAME    AS Addon_name,
            prod.PRICE   AS Addon_price,
            sprod.NAME   AS Sub_name,
            sprod.PRICE  AS Sub_prod,
            s.BINDING_PRICE,
            sa.CREATION_TIME                                            AS Addon_creation,
            sa.START_DATE                                               AS Addon_start,
            sa.END_DATE                                                 AS Addon_end,
            sa.EMPLOYEE_CREATOR_CENTER ||'emp'|| sa.EMPLOYEE_CREATOR_ID AS Salesperson_id,
            staff.FULLNAME                                              AS Salesperson_name,
            s.END_DATE                                                  AS Sub_end,
            CASE s.STATE
                WHEN 2
                THEN 'ACTIVE'
                WHEN 3
                THEN 'ENDED'
                WHEN 4
                THEN 'FROZEN'
                WHEN 7
                THEN 'WINDOW'
                WHEN 8
                THEN 'CREATED'
                ELSE 'Undefined'
            END AS Sub_state,
            p.sex,
            p.persontype,
            s.START_DATE,
            prod.center AS prod_center,
            prod.id     AS prod_id,
            p.center    AS per_center,
            p.id        AS per_id,
            s.center,
            s.id
        FROM
            SUBSCRIPTION_ADDON sa
        JOIN
            MASTERPRODUCTREGISTER mpr
        ON
            mpr.ID = sa.ADDON_PRODUCT_ID
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = sa.SUBSCRIPTION_CENTER
        AND prod.GLOBALID = mpr.GLOBALID
        AND prod.GLOBALID LIKE 'ALL_IN%'
        JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = sa.SUBSCRIPTION_CENTER
        AND s.ID = sa.SUBSCRIPTION_ID
        JOIN
            PRODUCTS sprod
        ON
            sprod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
        AND sprod.ID = s.SUBSCRIPTIONTYPE_ID
        JOIN
            PERSONS p
        ON
            p.CENTER = s.OWNER_CENTER
        AND p.ID = s.OWNER_ID
        JOIN
            EMPLOYEES emp
        ON
            emp.CENTER = sa.EMPLOYEE_CREATOR_CENTER
        AND emp.ID = sa.EMPLOYEE_CREATOR_ID
        JOIN
            PERSONS staff
        ON
            staff.center = emp.PERSONCENTER
        AND staff.id = emp.PERSONID
        WHERE
            p.center IN (:scope)
        AND sa.START_DATE <= current_timestamp ) t1
JOIN
    INVOICE_LINES_MT invl
ON
    invl.PERSON_CENTER = t1.per_center
AND invl.PERSON_ID = t1.per_id
AND invl.PRODUCTCENTER = t1.prod_center
AND invl.PRODUCTID = t1.prod_id
JOIN
    INVOICES inv
ON
    inv.CENTER = invl.CENTER
AND inv.ID = invl.ID
WHERE
    TO_CHAR(longtodate(t1.Addon_creation), 'dd-MM-YYYY') = TO_CHAR(longtodate(inv.ENTRY_TIME),
    'dd-MM-YYYY')
ORDER BY
t1.Addon_center,
"ADD-ON creation date"
