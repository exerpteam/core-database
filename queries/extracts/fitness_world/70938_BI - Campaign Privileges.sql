-- This is the version from 2026-02-05
--  
WITH
    params AS materialized
    (
        SELECT
            CASE $$offset$$
                WHEN -1
                THEN 0
                ELSE (TRUNC(CURRENT_TIMESTAMP)-$$offset$$-to_date('01-01-1970','DD-MM-YYYY'))*24*
                    3600*1000::bigint
            END                                                                        AS FROMDATE ,
            (TRUNC(CURRENT_TIMESTAMP+1)-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint AS
            TODATE
    )
    ,
    cte_subscriptions AS materialized
    (
        SELECT
            owner_center,
            owner_id,
            CREATION_TIME,
            subscriptiontype_center,
            subscriptiontype_id,
            s.center,
            s.id,
            s.INVOICELINE_CENTER,
            s.INVOICELINE_ID,
            s.INVOICELINE_SUBID
        FROM
            subscriptions s,
            params
        WHERE
            s.CREATION_TIME BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
        AND s.SUB_STATE <> 8
    )
    ,
    cte_persons AS materialized
    (
        SELECT
            cp.external_id         AS P_EXTERNALid,
            cp.CENTER||'p'|| cp.ID AS member_id,
            owner_center,
            CREATION_TIME,
            subscriptiontype_center,
            subscriptiontype_id,
            s.center,
            s.id,
            s.INVOICELINE_CENTER,
            s.INVOICELINE_ID,
            s.INVOICELINE_SUBID
        FROM
            cte_subscriptions s
        JOIN
            PERSONS p
        ON
            p.center = s.OWNER_CENTER
        AND p.ID = s.OWNER_ID
        JOIN
            PERSONS cp
        ON
            cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
        AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
    )
    ,
    cte_prvilege_usage AS materialized
    (
        SELECT
            CP.* ,
            INVL.PRODUCTCENTER,
            INVL.PRODUCTID,
            PU.GRANT_ID
        FROM
            cte_persons cp
        JOIN
            PRIVILEGE_USAGES pu
        ON
            cp.INVOICELINE_CENTER = pu.TARGET_CENTER
        AND cp.INVOICELINE_ID= pu.TARGET_ID
        AND cp.INVOICELINE_SUBID = pu.TARGET_SUBID
        JOIN
            invoice_lines_mt invl
        ON
            invl.CENTER = PU.TARGET_CENTER
        AND invl.ID = PU.TARGET_ID
        AND invl.SUBID = PU.TARGET_SUBID
        WHERE
            pu.TARGET_SERVICE = 'InvoiceLine'
    )
-- Startup campaign
SELECT DISTINCT
    cp.P_EXTERNALid                                                   AS "EXTERNAL_ID",
    member_id                                                         AS "MEMBERID",
    'Startup Campaign'                                                AS "SOURCETYPE",
    sc.NAME                                                           AS "CAMPAIGNNAME",
    ps.NAME                                                           AS "PRIVILEGESETNAME",
    TO_CHAR(longtodatec(sc.starttime, cp.owner_center), 'DD-MM-YYYY') AS "VALIDFROM",
    TO_CHAR(longtodatec(sc.endtime, cp.owner_center), 'DD-MM-YYYY')   AS "VALIDTO",
    CASE
        WHEN pp.price_modification_name IN ('FIXED_REBATE',
                                            'OVERRIDE')
        AND pp.privilege_set IS NOT NULL
        THEN 'Fixed price of ' || pp.price_modification_amount
        WHEN pp.price_modification_name IN ('PERCENTAGE_REBATE')
        AND pp.privilege_set IS NOT NULL
        THEN 'Rebate of ' || pp.price_modification_amount*100 || '%'
        WHEN pp2.price_modification_name IN ('FIXED_REBATE',
                                             'OVERRIDE')
        AND pp2.privilege_set IS NOT NULL
        THEN 'Fixed price of ' || pp2.price_modification_amount
        ELSE 'Rebate of ' || pp2.price_modification_amount*100 || '%'
    END                                                                           AS "PRICE",
    TO_CHAR(longtodateC(cp.CREATION_TIME, cp.owner_center), 'DD-MM-YYYY HH24:MI') AS "SUBSCRIPTIONCREATIONDATE",
    'Subscription'                                       AS "TYPE",
    TO_CHAR(prod.PRICE, 'FM99999999990.999999')::NUMERIC AS "PRODUCTPRICE",
    TO_CHAR((
            CASE
                WHEN pp.price_modification_name IN ('FIXED_REBATE',
                                                    'OVERRIDE')
                AND pp.privilege_set IS NOT NULL
                THEN pp.price_modification_amount
                WHEN pp.price_modification_name IN ('PERCENTAGE_REBATE')
                AND pp.privilege_set IS NOT NULL
                THEN (1 - pp.price_modification_amount) * prod.PRICE
                WHEN pp2.price_modification_name IN ('FIXED_REBATE',
                                                     'OVERRIDE')
                AND pp2.privilege_set IS NOT NULL
                THEN pp2.price_modification_amount
                ELSE (1 - pp2.price_modification_amount) * prod.PRICE
            END),'FM99999999990.999999')::NUMERIC AS "CAMPAIGNPRICE"
FROM
    cte_persons cp
JOIN
    SUBSCRIPTION_PRICE sp
ON
    sp.SUBSCRIPTION_CENTER = cp.CENTER
AND sp.SUBSCRIPTION_ID = cp.id
JOIN
    PRIVILEGE_USAGES pu
ON
    sp.ID = pu.TARGET_ID
JOIN
    PRIVILEGE_GRANTS pg
ON
    pg.ID = pu.GRANT_ID
JOIN
    STARTUP_CAMPAIGN sc
ON
    sc.ID = pg.GRANTER_ID
JOIN
    PRODUCTS prod
ON
    prod.CENTER = cp.subscriptiontype_center
AND prod.ID = cp.subscriptiontype_id
JOIN
    PRIVILEGE_SETS ps
ON
    ps.ID = pg.PRIVILEGE_SET
LEFT JOIN
    product_privileges pp
ON
    pp.privilege_set = ps.id
AND (
        pp.ref_globalid = prod.globalid
    OR  pp.ref_globalid IS NULL)
AND pp.price_modification_name IN ('FIXED_REBATE',
                                   'OVERRIDE',
                                   'PERCENTAGE_REBATE')
AND pp.valid_to IS NULL
AND pp.price_modification_amount IS NOT NULL
LEFT JOIN
    product_privileges pp2
ON
    pp2.privilege_set = ps.id
AND pp2.ref_globalid LIKE '%' || prod.globalid
AND pp2.price_modification_name IN ('FIXED_REBATE',
                                    'OVERRIDE',
                                    'PERCENTAGE_REBATE')
AND pp2.valid_to IS NULL
AND pp2.price_modification_amount IS NOT NULL
AND pp.privilege_set IS NULL
WHERE
    sp.CANCELLED = 0
AND pu.TARGET_SERVICE = 'SubscriptionPrice'
AND pg.GRANTER_SERVICE IN ('StartupCampaign')
UNION
-- Privilege campaign
SELECT
    cp.P_EXTERNALid                                              AS "EXTERNAL_ID",
    member_id                                                    AS "MEMBERID",
    'Privilege Campaign'                                         AS "SOURCETYPE",
    prg.NAME                                                     AS "CAMPAIGNNAME",
    ps.NAME                                                      AS "PRIVILEGESETNAME",
    TO_CHAR(longtodatec(prg.starttime, cp.center), 'DD-MM-YYYY')                  AS "VALIDFROM",
    TO_CHAR(longtodatec(prg.endtime, cp.center), 'DD-MM-YYYY')                    AS "VALIDTO",
    pp.price_modification_name                                                    AS "PRICE",
    TO_CHAR(longtodateC(cp.CREATION_TIME, cp.owner_center), 'DD-MM-YYYY HH24:MI') AS "SUBSCRIPTIONCREATIONDATE",
    'Joining fee' AS "TYPE",
    NULL          AS "PRODUCTPRICE",
    NULL          AS "CAMPAIGNPRICE"
FROM
    cte_prvilege_usage cp
JOIN
    PRIVILEGE_GRANTS pg
ON
    pg.id = cp.GRANT_ID
JOIN
    PRIVILEGE_RECEIVER_GROUPS prg
ON
    prg.ID = pg.GRANTER_ID
JOIN
    PRODUCTS prod
ON
    prod.CENTER = CP.PRODUCTCENTER
AND prod.ID = CP.PRODUCTID
JOIN
    PRIVILEGE_SETS ps
ON
    ps.ID = pg.PRIVILEGE_SET
JOIN
    product_privileges pp
ON
    pp.privilege_set = ps.id
WHERE
    pg.GRANTER_SERVICE = 'ReceiverGroup'
AND pp.ref_globalid LIKE '%' || prod.globalid
AND pp.price_modification_name = 'FREE'