-- This is the version from 2026-02-05
--  
WITH
    params AS MATERIALIZED
    (   SELECT
            TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD')-interval '5 days' AS fromDate,
            TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD')                   AS toDate,
            c.id                                                         AS centerID
        FROM
            centers c
        WHERE
            c.country = 'DK'
    )
    ,
    subs AS MATERIALIZED
    (   SELECT
            *
        FROM
            (   SELECT
                    ss.sales_date,
                    s.creation_time,
                    s.center,
                    s.id,
                    p.center AS per_center,
                    p.id     AS per_id,
                    cp.external_id,
                    pu.grant_id,
                    pu.privilege_id,
                    pr.globalid,
                    pr.price AS prod_price,
                    sp.from_date,
                    sp.to_date,
                    sp.price,
                    cc.code AS camp_code
                FROM
                    fw.subscription_sales ss
                JOIN
                    params par
                ON
                    par.centerid = ss.subscription_center
                JOIN
                    subscriptions s
                ON
                    s.center = ss.subscription_center
                AND s.id = ss.subscription_id
                JOIN
                    fw.subscription_price sp
                ON
                    sp.subscription_center = s.center
                AND sp.subscription_id = s.id
                JOIN
                    fw.privilege_usages pu
                ON
                    pu.target_id = sp.id
                AND pu.target_service = 'SubscriptionPrice'
                JOIN
                    subscriptiontypes st
                ON
                    st.center = s.subscriptiontype_center
                AND st.id = s.subscriptiontype_id
                JOIN
                    products pr
                ON
                    pr.center = st.center
                AND pr.id = st.id
                JOIN
                    persons p
                ON
                    p.center = s.owner_center
                AND p.id = s.owner_id
                JOIN
                    persons cp
                ON
                    cp.center = p.current_person_center
                AND cp.id = p.current_person_id
                LEFT JOIN
                    campaign_codes cc
                ON
                    cc.id = pu.campaign_code_id
                WHERE
                    ss.sales_date BETWEEN par.fromDate AND par.toDate
                AND sp.cancelled = 0
                AND pu.state NOT IN ('CANCELLED')
                
                UNION ALL
                
                SELECT
                    ss.sales_date,
                    s.creation_time,
                    s.center,
                    s.id,
                    p.center AS per_center,
                    p.id     AS per_id,
                    cp.external_id,
                    pu.grant_id,
                    pu.privilege_id,
                    pr.globalid,
                    pr.price,
                    sup.from_date,
                    sup.to_date,
                    sup.price,
                    cc.code AS camp_code
                FROM
                    fw.subscription_sales ss
                JOIN
                    params par
                ON
                    par.centerid = ss.subscription_center
                JOIN
                    subscriptions s
                ON
                    s.center = ss.subscription_center
                AND s.id = ss.subscription_id
                JOIN
                    (   SELECT
                            sp.subscription_center,
                            sp.subscription_id,
                            sp.from_date,
                            sp.to_date,
                            sp.price,
                            RANK() over (
                                     PARTITION BY
                                         sp.subscription_center,
                                         sp.subscription_id
                                     ORDER BY
                                         sp.from_date ASC) ranking
                        FROM
                            fw.subscription_price sp
                        WHERE
                            sp.cancelled = false ) sup
                ON
                    sup.subscription_center = s.center
                AND sup.subscription_id = s.id
                AND sup.ranking = 1
                JOIN
                    fw.privilege_usages pu
                ON
                    pu.target_center = s.invoiceline_center
                AND pu.target_id = s.invoiceline_id
                AND pu.target_service = 'InvoiceLine'
                JOIN
                    invoice_lines_mt invl
                ON
                    invl.center = pu.target_center
                AND invl.id = pu.target_id
                AND invl.subid = pu.target_subid
                JOIN
                    products pr
                ON
                    pr.center = invl.productcenter
                AND pr.id = invl.productid
                JOIN
                    persons p
                ON
                    p.center = s.owner_center
                AND p.id = s.owner_id
                JOIN
                    persons cp
                ON
                    cp.center = p.current_person_center
                AND cp.id = p.current_person_id
                LEFT JOIN
                    campaign_codes cc
                ON
                    cc.id = pu.campaign_code_id
                WHERE
                    ss.sales_date BETWEEN par.fromDate AND par.toDate
                AND pu.state NOT IN ('CANCELLED') )t
            --WHERE
            --  t.center IN (scope)
    )
    ,
    product_prices AS MATERIALIZED
    (   SELECT
            pp.id,
            pp.price_modification_name,
            pp.price_modification_amount,
            ps.name
        FROM
            product_privileges pp
        JOIN
            privilege_sets ps
        ON
            ps.id = pp.privilege_set
        WHERE
            pp.price_modification_name != 'NONE'
        GROUP BY
            pp.id,
            pp.price_modification_name,
            pp.price_modification_amount,
            ps.name
    )
SELECT
    external_id                     AS "EXTERNAL_ID",
    member_id                       AS "MEMBERID",
    sub_id                          AS "SUBSCRIPTIONID",
    price_from                      AS "PRICEFROM",
    price_to                        AS "PRICETO",
    campaign_code                   AS "CAMPAIGNCODE",
    campaign_id                     AS "CAMPAIGNID",
    campaign_type                   AS "SOURCETYPE",
    campaign_name                   AS "CAMPAIGNNAME",
    string_agg(priv_set_name, ', ') AS "PRIVILEGESETNAME",
    campaign_valid_from             AS "VALIDFROM",
    campaign_valid_to               AS "VALIDTO",
    discount_type                   AS "PRICE",
    sub_creation_date               AS "SUBSCRIPTIONCREATIONDATE",
    product_type                    AS "TYPE",
    prod_price                      AS "PRODUCTPRICE",
    campaign_price                  AS "CAMPAIGNPRICE"
FROM
    (
        --startup campaigns
        SELECT
            su.external_id,
            su.per_center ||'p'|| su.per_id AS member_id,
            su.center ||'ss'|| su.id        AS sub_id,
            CASE
                WHEN su.from_date IS NULL
                THEN '1900-01-01'
                ELSE su.from_date
            END AS price_from,
            CASE
                WHEN su.to_date IS NULL
                THEN '2099-12-31'
                ELSE su.to_date
            END                                                          AS price_to,
            su.camp_code                                                    AS campaign_code,
            sc.id                                                           AS campaign_id,
            'Startup Campaign'                                              AS campaign_type,
            sc.name                                                         AS campaign_name,
            prp.name                                                        AS priv_set_name,
            TO_CHAR(longtodatec(sc.starttime, su.per_center), 'DD-MM-YYYY') AS campaign_valid_from
            ,
            TO_CHAR(longtodatec(sc.endtime, su.per_center), 'DD-MM-YYYY') AS campaign_valid_to,
            CASE
                WHEN prp.price_modification_name = 'OVERRIDE'
                THEN 'Fixed price of ' || prp.price_modification_amount
                WHEN prp.price_modification_name = 'FIXED_REBATE'
                THEN 'Fixed price of ' || su.prod_price-prp.price_modification_amount
                WHEN prp.price_modification_name = 'PERCENTAGE_REBATE'
                THEN 'Rebate of ' || prp.price_modification_amount*100 || '%'
                WHEN prp.price_modification_name = 'FREE'
                THEN 'Free'
            END                                                                    AS discount_type,
            TO_CHAR(longtodateC(su.creation_time, su.per_center), 'DD-MM-YYYY HH24:MI') AS
                              sub_creation_date,
            'Subscription'                                          AS product_type,
            TO_CHAR(su.prod_price, 'FM99999999990.999999')::NUMERIC AS prod_price,
            TO_CHAR((
            CASE
                WHEN prp.price_modification_name = 'OVERRIDE'
                THEN prp.price_modification_amount
                WHEN prp.price_modification_name = 'FIXED_REBATE'
                THEN su.prod_price-prp.price_modification_amount
                WHEN prp.price_modification_name = 'PERCENTAGE_REBATE'
                THEN (1 - prp.price_modification_amount) * su.prod_price
                WHEN prp.price_modification_name = 'FREE'
                THEN 0
            END),'FM99999999990.999999')::NUMERIC AS campaign_price
        FROM
            subs su
        JOIN
            fw.privilege_grants pg
        ON
            pg.id = su.grant_id
        JOIN
            startup_campaign sc
        ON
            sc.id = pg.granter_id
        JOIN
            product_prices prp
        ON
            prp.id = su.privilege_id
        WHERE
            pg.granter_service = 'StartupCampaign'
        AND su.globalid NOT LIKE 'CREATION_%'
        
        UNION ALL
        
        --Target groups and privilege campaigns
        SELECT
            su.external_id,
            su.per_center ||'p'|| su.per_id AS member_id,
            su.center ||'ss'|| su.id        AS sub_id,
            CASE
                WHEN su.from_date IS NULL
                THEN '1900-01-01'
                ELSE su.from_date
            END AS price_from,
            CASE
                WHEN su.to_date IS NULL
                THEN '2099-12-31'
                ELSE su.to_date
            END          AS price_to,
            su.camp_code AS campaign_code,
            prg.id       AS campaign_id,
            CASE
                WHEN prg.rgtype = 'UNLIMITED'
                THEN 'Target Group'
                WHEN prg.rgtype = 'CAMPAIGN'
                THEN 'Privilege Campaign'
            END                                                              AS campaign_type,
            prg.name                                                         AS campaign_name,
            prp.name                                                         AS priv_set_name,
            TO_CHAR(longtodatec(prg.starttime, su.per_center), 'DD-MM-YYYY') AS
                                                                              campaign_valid_from,
            TO_CHAR(longtodatec(prg.endtime, su.per_center), 'DD-MM-YYYY') AS campaign_valid_to,
            CASE
                WHEN prp.price_modification_name = 'OVERRIDE'
                THEN 'Fixed price of ' || prp.price_modification_amount
                WHEN prp.price_modification_name = 'FIXED_REBATE'
                THEN 'Fixed price of ' || su.prod_price-prp.price_modification_amount
                WHEN prp.price_modification_name = 'PERCENTAGE_REBATE'
                THEN 'Rebate of ' || prp.price_modification_amount*100 || '%'
                WHEN prp.price_modification_name = 'FREE'
                THEN 'Free'
            END                                                                    AS discount_type,
            TO_CHAR(longtodateC(su.creation_time, su.per_center), 'DD-MM-YYYY HH24:MI') AS
                              sub_creation_date,
            'Subscription'                                          AS product_type,
            TO_CHAR(su.prod_price, 'FM99999999990.999999')::NUMERIC AS prod_price,
            TO_CHAR((
            CASE
                WHEN prp.price_modification_name = 'OVERRIDE'
                THEN prp.price_modification_amount
                WHEN prp.price_modification_name = 'FIXED_REBATE'
                THEN su.prod_price-prp.price_modification_amount
                WHEN prp.price_modification_name = 'PERCENTAGE_REBATE'
                THEN (1 - prp.price_modification_amount) * su.prod_price
                WHEN prp.price_modification_name = 'FREE'
                THEN 0
            END),'FM99999999990.999999')::NUMERIC AS campaign_price
        FROM
            subs su
        JOIN
            fw.privilege_grants pg
        ON
            pg.id = su.grant_id
        JOIN
            privilege_receiver_groups prg
        ON
            prg.id = pg.granter_id
        JOIN
            product_prices prp
        ON
            prp.id = su.privilege_id
        WHERE
            pg.granter_service = 'ReceiverGroup'
        AND su.globalid NOT LIKE 'CREATION_%'
        
        UNION ALL
        
        --Joining fee
        SELECT
            su.external_id,
            su.per_center ||'p'|| su.per_id AS member_id,
            su.center ||'ss'|| su.id        AS sub_id,
            '1900-01-01'                    AS price_from,
            '2099-12-31'                    AS price_to,
            su.camp_code                    AS campaign_code,
            prg.id                          AS campaign_id,
            CASE
                WHEN prg.rgtype = 'UNLIMITED'
                THEN 'Target Group'
                WHEN prg.rgtype = 'CAMPAIGN'
                THEN 'Privilege Campaign'
            END                                                              AS campaign_type,
            prg.name                                                         AS campaign_name,
            prp.name                                                         AS priv_set_name,
            TO_CHAR(longtodatec(prg.starttime, su.per_center), 'DD-MM-YYYY') AS
                                                                              campaign_valid_from,
            TO_CHAR(longtodatec(prg.endtime, su.per_center), 'DD-MM-YYYY') AS campaign_valid_to,
            CASE
                WHEN prp.price_modification_name = 'OVERRIDE'
                THEN 'Fixed price of ' || prp.price_modification_amount
                WHEN prp.price_modification_name = 'FIXED_REBATE'
                THEN 'Fixed price of ' || su.prod_price-prp.price_modification_amount
                WHEN prp.price_modification_name = 'PERCENTAGE_REBATE'
                THEN 'Rebate of ' || prp.price_modification_amount*100 || '%'
                WHEN prp.price_modification_name = 'FREE'
                THEN 'Free'
            END                                                                    AS discount_type,
            TO_CHAR(longtodateC(su.creation_time, su.per_center), 'DD-MM-YYYY HH24:MI') AS
                             sub_creation_date,
            'Joining fee'                                      AS product_type,
            TO_CHAR(jo.price, 'FM99999999990.999999')::NUMERIC AS prod_price,
            TO_CHAR((
            CASE
                WHEN prp.price_modification_name = 'OVERRIDE'
                THEN prp.price_modification_amount
                WHEN prp.price_modification_name = 'FIXED_REBATE'
                THEN su.prod_price-prp.price_modification_amount
                WHEN prp.price_modification_name = 'PERCENTAGE_REBATE'
                THEN (1 - prp.price_modification_amount) * su.prod_price
                WHEN prp.price_modification_name = 'FREE'
                THEN 0
            END),'FM99999999990.999999')::NUMERIC AS campaign_price
        FROM
            subs su
        JOIN
            fw.privilege_grants pg
        ON
            pg.id = su.grant_id
        JOIN
            privilege_receiver_groups prg
        ON
            prg.id = pg.granter_id
        JOIN
            product_prices prp
        ON
            prp.id = su.privilege_id
        JOIN
            products jo
        ON
            jo.globalid = su.globalid
        AND jo.center = su.center
        WHERE
            pg.granter_service = 'ReceiverGroup'
        AND su.globalid LIKE 'CREATION_%') sub
GROUP BY
    "EXTERNAL_ID",
    "MEMBERID",
    "SUBSCRIPTIONID",
    "PRICEFROM",
    "PRICETO",
    "CAMPAIGNCODE",
    "CAMPAIGNID",
    "SOURCETYPE",
    "CAMPAIGNNAME",
    "VALIDFROM",
    "VALIDTO",
    "PRICE",
    "SUBSCRIPTIONCREATIONDATE",
    "TYPE",
    "PRODUCTPRICE",
    "CAMPAIGNPRICE"
ORDER BY
    "SUBSCRIPTIONCREATIONDATE"