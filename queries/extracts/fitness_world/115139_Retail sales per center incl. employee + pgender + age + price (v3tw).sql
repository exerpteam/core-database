-- This is the version from 2026-02-05
--  
WITH
    price_history AS materialized
    (
        WITH
            pmp_xml AS
            (
                SELECT
                    m.id,
                    CAST(convert_from(m.product, 'UTF-8') AS XML) AS pxml
                FROM
                    masterproductregister m
            )
        SELECT
            t1.*
        FROM
            (
                SELECT
                    m2.id,
                    m2.globalid,
                    UNNEST(xpath('//prices/price/normalPrice/text()', pmp_xml.pxml)) AS
                                                                                     normal_price,
                    UNNEST(xpath('//prices/price/minPrice/text()', pmp_xml.pxml))  AS min_price,
                    UNNEST(xpath('//prices/price/costPrice/text()', pmp_xml.pxml)) AS cost_price,
                    UNNEST(xpath('//prices/price/@start', pmp_xml.pxml))           AS start_date,
   m2.scope_type                                                  AS
                                   mpr_scope_type,
                    m2.scope_id AS mpr_scope_id
                FROM
                    pmp_xml,
                    masterproductregister m2
                WHERE
                    m2.id = pmp_xml.id
                AND m2.cached_producttype = 1) t1
    )
    ,
    params AS materialized
    (
        SELECT
            CAST($$From_Date$$ AS BIGINT)                      AS FromDate,
            (CAST($$To_Date$$ AS BIGINT) + 86400 * 1000) - 1 AS ToDate
    )
 ,
    scope_tree AS materialized
    (
        WITH
            RECURSIVE centers_in_area AS
            (
                SELECT
                    a.id,
                    a.parent,
                    ARRAY[id] AS chain_of_command_ids,
                    2         AS level
                FROM
                    areas a
                WHERE
                    a.types LIKE '%system%'
                AND a.parent IS NULL
                UNION ALL
                SELECT
                    a.id,
                    a.parent,
                    array_append(cin.chain_of_command_ids, a.id) AS chain_of_command_ids,
                    cin.level + 1                                AS level
                FROM
                    areas a
                JOIN
                    centers_in_area cin
                ON
                    cin.id = a.parent
            )
            ,
            areas_total AS
            (
                SELECT
                    cin.id AS ID,
                    cin.level,
                    unnest(array_remove(array_agg(b.ID), NULL)) AS sub_areas
                FROM
                    centers_in_area cin
                LEFT JOIN
                    centers_in_area AS b -- join provides subordinates
                ON
                    cin.id = ANY (b.chain_of_command_ids)
                AND cin.level <= b.level
                GROUP BY
                    1,2
            )
        SELECT
            'A'               AS SCOPE_TYPE,
            areas_total.ID    AS SCOPE_ID,
            c.ID              AS center_id,
            areas_total.level AS "LEVEL"
        FROM
            areas_total
        LEFT JOIN
            area_centers ac
        ON
            ac.area = areas_total.sub_areas
        JOIN
            centers c
        ON
            ac.CENTER = c.id
        UNION ALL
        SELECT
            'C'  AS "SCOPE_TYPE",
            c.ID AS "SCOPE_ID",
            c.ID AS "CENTER_ID",
            999  AS "LEVEL"
        FROM
            centers c
        UNION ALL
        SELECT
            'G'  AS "SCOPE_TYPE",
            0    AS "SCOPE_ID",
            c.ID AS "CENTER_ID",
            0    AS "LEVEL"
        FROM
            centers c
        UNION ALL
        SELECT
            'T'  AS "SCOPE_TYPE",
            a.ID AS "SCOPE_ID",
            c.id AS "CENTER_ID",
            1    AS "LEVEL"
        FROM
            areas a
        CROSS JOIN
            centers c
        WHERE
            a.id = a.root_area
    )
    ,
    eligible_products AS materialized
    (
        SELECT
            c.ID,
            cea.TXT_VALUE           AS Region,
            productGroup.NAME          product_group_name,
            p.CENTER || 'p' || p.ID    payer_id,
            p.external_ID,
            p.sex,
            floor(months_between(TRUNC(CURRENT_TIMESTAMP),p.BIRTHDATE)/12) age,
            p.BIRTHDATE,
            p.FIRSTNAME || ' ' || p.LASTNAME payer_name,
            CASE p.PERSONTYPE
                WHEN 0
                THEN 'PRIVATE'
                WHEN 1
                THEN 'STUDENT'
                WHEN 2
                THEN 'STAFF'
                WHEN 3
                THEN 'FRIEND'
                WHEN 4
                THEN 'CORPORATE'
                WHEN 5
                THEN 'ONEMANCORPORATE'
                WHEN 6
                THEN 'FAMILY'
                WHEN 7
                THEN 'SENIOR'
                WHEN 8
                THEN 'GUEST'
                ELSE 'UNKNOWN'
            END           AS "Person Type",
            prod.GLOBALID    product,
            prod.name     AS product_name,
            CASE prod.PTYPE
                WHEN 1
                THEN 'Retail'
                WHEN 2
                THEN 'Service'
                WHEN 4
                THEN 'Clipcard'
                WHEN 5
                THEN 'Subscription creation'
                WHEN 6
                THEN 'Transfer'
                WHEN 7
                THEN 'Freeze period'
                WHEN 8
                THEN 'Gift card'
                WHEN 9
                THEN 'Free gift card'
                WHEN 10
                THEN 'Subscription'
                WHEN 12
                THEN 'Subscription pro-rata'
            END product_type,
            SUM (
                CASE
                    WHEN invl.SPONSOR_INVOICE_SUBID IS NULL
                    THEN 1 * invl.QUANTITY
                    ELSE 0
                END )                           AS SOLD_UNITS,
            REPLACE('' || prod.PRICE, '.', ',') AS NORMAL_UNIT_PRICE,
            prod.cost_price                     AS Cost_Price,
            ROUND(SUM(invl.TOTAL_AMOUNT - (invl.TOTAL_AMOUNT - (invl.TOTAL_AMOUNT/ (1 + invl.RATE))
            )),2)                                                                AS AMOUNT_EXCL_VAT,
            ROUND(SUM(invl.TOTAL_AMOUNT - (invl.TOTAL_AMOUNT/ (1 + invl.RATE))),2) AS VAT_AMOUNT,
            ROUND(SUM(invl.TOTAL_AMOUNT),2)                                        AS
                                                           AMOUNT_INCL_VAT,
            inv.EMPLOYEE_CENTER||'emp'||inv.EMPLOYEE_ID      AS staff,
            staffp.fullname                                  AS staff_name,
            TO_CHAR(longtodate(inv.TRANS_TIME),'yyyy-MM-dd') AS "Invoice Date",
            TO_CHAR(longtodate(inv.TRANS_TIME),'HH24:MI')    AS "Invoice Time",
            cr.NAME                                          AS CashRegister,
            CASE
                WHEN pg.GRANTER_SERVICE = 'GlobalCard'
                THEN 'CLIPCARD'
                WHEN pg.GRANTER_SERVICE = 'GlobalSubscription'
                THEN 'SUBSCRIPTION'
                WHEN pg.GRANTER_SERVICE = 'Addon'
                THEN 'SUBSCRIPTION_ADDON'
                WHEN pg.GRANTER_SERVICE = 'ReceiverGroup'
                AND rg.RGTYPE ='CAMPAIGN'
                THEN 'CAMPAIGN'
                WHEN pg.GRANTER_SERVICE = 'ReceiverGroup'
                AND rg.RGTYPE ='UNLIMITED'
                THEN 'TARGET_GROUP'
                WHEN pg.GRANTER_SERVICE = 'StartupCampaign'
                THEN 'STARTUP_CAMPAIGN'
                WHEN pg.GRANTER_SERVICE = 'CompanyAgreement'
                THEN 'COMPANY_AGREEMENT'
                WHEN pg.GRANTER_SERVICE = 'Access product'
                THEN 'ACCESS_PRODUCT'
                WHEN pg.GRANTER_SERVICE IS NULL
                THEN NULL
                ELSE 'UNDEFINED'
            END priv_source_type,
            CASE
                WHEN pg.GRANTER_SERVICE = 'GlobalCard'
                THEN pu.SOURCE_CENTER || 'cc' || pu.SOURCE_ID ||'cc'|| pu.SOURCE_SUBID
                WHEN pg.GRANTER_SERVICE = 'GlobalSubscription'
                THEN pu.SOURCE_CENTER || 'ss' || pu.SOURCE_ID
                WHEN pg.GRANTER_SERVICE = 'Addon'
                THEN '' || pu.SOURCE_ID
                WHEN pg.GRANTER_SERVICE = 'ReceiverGroup'
                AND rg.RGTYPE ='CAMPAIGN'
                THEN 'C_' || pu.SOURCE_ID
                WHEN pg.GRANTER_SERVICE = 'ReceiverGroup'
                AND rg.RGTYPE ='UNLIMITED'
                THEN 'TG_' || pu.SOURCE_ID
                WHEN pg.GRANTER_SERVICE = 'StartupCampaign'
                THEN 'SC_' || pg.GRANTER_ID
                WHEN pg.GRANTER_SERVICE = 'CompanyAgreement'
                THEN pg.GRANTER_CENTER || 'p' || pg.GRANTER_ID || 'rpt' || pg.GRANTER_SUBID
                WHEN pg.GRANTER_SERVICE = 'Access product'
                THEN pu.SOURCE_CENTER || 'inv' || pu.SOURCE_ID ||'ln'|| pu.SOURCE_SUBID
                WHEN pg.GRANTER_SERVICE IS NULL
                THEN NULL
                ELSE 'N/A'
            END priv_source_id,ps.name as priv_set_name,
            case WHEN pg.GRANTER_SERVICE = 'GlobalCard'
                THEN cc.name
                WHEN pg.GRANTER_SERVICE = 'GlobalSubscription'
                THEN spr.name
                WHEN pg.GRANTER_SERVICE = 'Addon'
                THEN ampr.cached_productname
                WHEN pg.GRANTER_SERVICE = 'ReceiverGroup'
                then rg.name
                WHEN pg.GRANTER_SERVICE = 'CompanyAgreement'
                THEN pg.GRANTER_CENTER || 'p' || pg.GRANTER_ID || 'rpt' || pg.GRANTER_SUBID
                WHEN pg.GRANTER_SERVICE = 'Access product'
                THEN appr.name
                WHEN pg.GRANTER_SERVICE IS NULL
                THEN NULL
                ELSE 'N/A' end as priv_source_name,
prod.center AS prod_center
        FROM
            INVOICELINES invl
        CROSS JOIN
            params
        JOIN
            INVOICES inv
        ON
            invl.CENTER = inv.CENTER
        AND invl.id = inv.id
        LEFT JOIN
            FW.PERSONS p
        ON
            p.CENTER = inv.PAYER_CENTER
        AND p.ID = inv.PAYER_ID
        JOIN
            FW.CENTERS c
        ON
            c.id = invl.CENTER
        LEFT JOIN
            CENTER_EXT_ATTRS cea
        ON
            c.ID = cea.CENTER_ID
        AND cea.NAME = 'Region'
        JOIN
            FW.PRODUCTS prod
        ON
            prod.ID = invl.PRODUCTID
        AND prod.CENTER = invl.PRODUCTCENTER
        JOIN
            FW.PRODUCT_GROUP productGroup
        ON
            prod.PRIMARY_PRODUCT_GROUP_ID = productGroup.id
        LEFT JOIN
            FW.employees staff
        ON
            inv.EMPLOYEE_CENTER = staff.center
        AND inv.EMPLOYEE_ID = staff.id
        LEFT JOIN
            FW.persons staffp
        ON
            staff.personcenter = staffp.center
        AND staff.personid = staffp.id
        LEFT JOIN
            CASHREGISTERS cr
        ON
            inv.CASHREGISTER_CENTER = cr.CENTER
        AND inv.CASHREGISTER_ID = cr.ID
        LEFT JOIN
            PRIVILEGE_USAGES pu
        ON
            pu.TARGET_SERVICE = 'InvoiceLine'
        AND pu.TARGET_CENTER = invl.center
        AND pu.TARGET_ID = invl.id
        AND pu.TARGET_SUBID = invl.subid
        LEFT JOIN
            PRIVILEGE_GRANTS pg
        ON
            pg.ID = pu.GRANT_ID
        LEFT JOIN
            PRIVILEGE_RECEIVER_GROUPS rg
        ON
            pg.GRANTER_SERVICE = 'ReceiverGroup'
        AND rg.ID = pu.SOURCE_ID
        left join fw.privilege_sets ps on ps.id = pg.privilege_set
        left join fw.products cc on pu.SOURCE_CENTER =cc.center and  pu.SOURCE_ID = cc.id and pg.GRANTER_SERVICE = 'GlobalCard'
        left join fw.subscriptions s on s.center = pu.SOURCE_CENTER and s.id = pu.SOURCE_ID and pg.GRANTER_SERVICE = 'GlobalSubscription'
        left join fw.products spr on spr.center = s.subscriptiontype_center and spr.id = s.subscriptiontype_id
        left join fw.subscription_addon sa on sa.id = pu.source_id and pg.GRANTER_SERVICE = 'Addon'
        left join fw.masterproductregister ampr on ampr.id = sa.addon_product_id
        left join fw.invoice_lines_mt il on il.center = pu.SOURCE_CENTER and il.id = pu.SOURCE_ID and il.subid = pu.SOURCE_SUBID and pg.GRANTER_SERVICE = 'Access product'
        left join fw.products appr on appr.center = il.productcenter and appr.id = il.productid
        
        WHERE
            inv.TRANS_TIME >= params.FromDate
        AND inv.TRANS_TIME <= params.ToDate
        AND inv.center IN ($$scope$$)
        AND NOT EXISTS
            (
                SELECT
                    *
                FROM
                    FW.CREDIT_NOTE_LINES cnl
                WHERE
                    cnl.INVOICELINE_CENTER = invl.CENTER
                AND cnl.INVOICELINE_ID = invl.id
                AND cnl.INVOICELINE_SUBID = invl.SUBID )
        AND prod.PTYPE = 1 -- RETAIL PRODUCTS
        GROUP BY
            c.ID,
            cea.TXT_VALUE,
            p.sex,
            months_between(TRUNC(CURRENT_TIMESTAMP),p.BIRTHDATE)/12,
            p.BIRTHDATE,
            prod.name,
            prod.GLOBALID,
            prod.PRICE,
            prod.cost_price,
            inv.EMPLOYEE_CENTER,
            inv.EMPLOYEE_ID,
            staffp.fullname,
            P.PERSONTYPE,
            productGroup.NAME,
            p.CENTER,
            p.ID,
            p.external_ID,
            payer_id,
            p.FIRSTNAME,
            p.LASTNAME,
            prod.PTYPE,
            TO_CHAR(longtodate(inv.TRANS_TIME),'yyyy-MM-dd') ,
            TO_CHAR(longtodate(inv.TRANS_TIME),'HH24:MI'),
            cr.NAME,
            pg.granter_service,
            rg.rgtype,
            pu.source_center,
            pu.source_id,
            pu.source_subid,
            pg.granter_id,
            pg.granter_center,
prod.center,
            pg.granter_subid,ps.name,cc.name,spr.name,rg.name,appr.name,ampr.cached_productname
        ORDER BY
            prod.GLOBALID
    )
SELECT
    t2.id,
    t2.Region,
    t2.product_group_name,
    t2.payer_id,
    t2.external_ID,
    t2.sex,
    t2.age,
    t2.birthdate,
    t2.payer_name,
    t2."Person Type",
    t2.product,
    t2.product_name,
    t2.product_type,
    t2.sold_units,
    CAST((t2.ph_normal_price ::text) AS DECIMAL) AS normal_price,
    CAST((t2.ph_cost_price ::text) AS DECIMAL)   AS cost_price,
    t2.amount_excl_vat,
    t2.amount_incl_vat,
    t2.staff,
    t2.staff_name,
    t2."Invoice Date",
    t2."Invoice Time",
    t2.CashRegister,
    t2.priv_source_type as "Privilege Source Type",
    t2.priv_source_id as "Privilege Source ID",
    priv_set_name as "Privilege Set Name",
    t2.priv_source_name as "Privilege Source Name"
FROM
    (
        
  SELECT DISTINCT ON (ep.payer_id, ep.product, ep."Invoice Date", ep."Invoice Time")
    ep.*,
    ph.normal_price AS ph_normal_price,
    ph.cost_price   AS ph_cost_price
  FROM eligible_products ep
  JOIN price_history ph
    ON ph.globalid = ep.product
   AND CAST(ep."Invoice Date" AS DATE) > CAST(ph.start_date ::text AS DATE)
  JOIN scope_tree st
    ON ep.prod_center    = st.center_id
   AND ph.mpr_scope_type = st.scope_type
   AND ph.mpr_scope_id   = st.scope_id
  ORDER BY
    ep.payer_id, ep.product, ep."Invoice Date", ep."Invoice Time",
    st."LEVEL", CAST(ph.start_date ::text AS DATE) DESC
) t2
ORDER BY
    t2.product,
    t2.id,
    t2.region,
    t2.age