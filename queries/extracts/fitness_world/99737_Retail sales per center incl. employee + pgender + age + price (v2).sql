-- This is the version from 2026-02-05
-- EC-7621
WITH
    price_history AS MATERIALIZED (
        WITH pmp_xml AS (
            SELECT
                m.id,
                CAST(convert_from(m.product, 'UTF-8') AS XML) AS pxml
            FROM masterproductregister m
        )
        SELECT
            t1.*
        FROM (
            SELECT
                m2.id,
                m2.globalid,
                UNNEST(xpath('//prices/price/normalPrice/text()', pmp_xml.pxml)) AS normal_price,
                UNNEST(xpath('//prices/price/minPrice/text()', pmp_xml.pxml))  AS min_price,
                UNNEST(xpath('//prices/price/costPrice/text()', pmp_xml.pxml)) AS cost_price,
                UNNEST(xpath('//prices/price/@start', pmp_xml.pxml))           AS start_date,
                m2.scope_type AS mpr_scope_type,
                m2.scope_id AS mpr_scope_id
            FROM
                pmp_xml
            JOIN masterproductregister m2 ON m2.id = pmp_xml.id
            WHERE
                m2.cached_producttype = 1
        ) t1
    ),

    params AS MATERIALIZED (
        SELECT
            CAST($$From_Date$$ AS BIGINT) AS FromDate,
            (CAST($$To_Date$$ AS BIGINT) + 86400 * 1000) - 1 AS ToDate
    ),

    scope_tree AS MATERIALIZED (
        WITH RECURSIVE centers_in_area AS (
            SELECT
                a.id,
                a.parent,
                ARRAY[id] AS chain_of_command_ids,
                2 AS level
            FROM areas a
            WHERE a.types LIKE '%system%' AND a.parent IS NULL

            UNION ALL

            SELECT
                a.id,
                a.parent,
                array_append(cin.chain_of_command_ids, a.id),
                cin.level + 1
            FROM areas a
            JOIN centers_in_area cin ON cin.id = a.parent
        ),

        areas_total AS (
            SELECT
                cin.id AS id,
                cin.level,
                unnest(array_remove(array_agg(b.id), NULL)) AS sub_areas
            FROM centers_in_area cin
            LEFT JOIN centers_in_area b
                ON cin.id = ANY (b.chain_of_command_ids)
               AND cin.level <= b.level
            GROUP BY 1, 2
        )

        SELECT
            'A' AS scope_type,
            areas_total.id AS scope_id,
            c.id AS center_id,
            areas_total.level AS level
        FROM areas_total
        LEFT JOIN area_centers ac ON ac.area = areas_total.sub_areas
        JOIN centers c ON ac.center = c.id

        UNION ALL
        SELECT 'C', c.id, c.id, 999 FROM centers c

        UNION ALL
        SELECT 'G', 0, c.id, 0 FROM centers c

        UNION ALL
        SELECT 'T', a.id, c.id, 1
        FROM areas a
        CROSS JOIN centers c
        WHERE a.id = a.root_area
    ),

    eligible_products AS MATERIALIZED (
        SELECT
            c.id,
            cea.txt_value AS region,
            productGroup.name AS product_group_name,
            p.center || 'p' || p.id AS payer_id,
            p.external_id,
            mpr.cached_external_id AS master_cached_external_id,   
            p.sex,
            FLOOR(months_between(TRUNC(CURRENT_TIMESTAMP), p.birthdate) / 12) AS age,
            p.birthdate,
            p.firstname || ' ' || p.lastname AS payer_name,
            CASE p.persontype
                WHEN 0 THEN 'PRIVATE'
                WHEN 1 THEN 'STUDENT'
                WHEN 2 THEN 'STAFF'
                WHEN 3 THEN 'FRIEND'
                WHEN 4 THEN 'CORPORATE'
                WHEN 5 THEN 'ONEMANCORPORATE'
                WHEN 6 THEN 'FAMILY'
                WHEN 7 THEN 'SENIOR'
                WHEN 8 THEN 'GUEST'
                ELSE 'UNKNOWN'
            END AS "Person Type",
            prod.globalid AS product,
            prod.name AS product_name,
            CASE prod.ptype
                WHEN 1 THEN 'Retail'
                WHEN 2 THEN 'Service'
                WHEN 4 THEN 'Clipcard'
                WHEN 5 THEN 'Subscription creation'
                WHEN 6 THEN 'Transfer'
                WHEN 7 THEN 'Freeze period'
                WHEN 8 THEN 'Gift card'
                WHEN 9 THEN 'Free gift card'
                WHEN 10 THEN 'Subscription'
                WHEN 12 THEN 'Subscription pro-rata'
            END AS product_type,
            SUM(CASE WHEN invl.sponsor_invoice_subid IS NULL THEN invl.quantity ELSE 0 END) AS sold_units,
            REPLACE('' || prod.price, '.', ',') AS normal_unit_price,
            prod.cost_price AS cost_price,
            ROUND(SUM(invl.total_amount - (invl.total_amount - (invl.total_amount / (1 + invl.rate)))), 2)
                AS amount_excl_vat,
            ROUND(SUM(invl.total_amount - (invl.total_amount / (1 + invl.rate))), 2) AS vat_amount,
            ROUND(SUM(invl.total_amount), 2) AS amount_incl_vat,
            inv.employee_center || 'emp' || inv.employee_id AS staff,
            staffp.fullname AS staff_name,
            TO_CHAR(longtodate(inv.trans_time), 'yyyy-MM-dd') AS "Invoice Date",
            TO_CHAR(longtodate(inv.trans_time), 'HH24:MI') AS "Invoice Time",
            cr.name AS cashregister,

            CASE
                WHEN pg.granter_service = 'GlobalCard' THEN 'CLIPCARD'
                WHEN pg.granter_service = 'GlobalSubscription' THEN 'SUBSCRIPTION'
                WHEN pg.granter_service = 'Addon' THEN 'SUBSCRIPTION_ADDON'
                WHEN pg.granter_service = 'ReceiverGroup' AND rg.rgtype = 'CAMPAIGN' THEN 'CAMPAIGN'
                WHEN pg.granter_service = 'ReceiverGroup' AND rg.rgtype = 'UNLIMITED' THEN 'TARGET_GROUP'
                WHEN pg.granter_service = 'StartupCampaign' THEN 'STARTUP_CAMPAIGN'
                WHEN pg.granter_service = 'CompanyAgreement' THEN 'COMPANY_AGREEMENT'
                WHEN pg.granter_service = 'Access product' THEN 'ACCESS_PRODUCT'
                ELSE NULL
            END AS priv_source_type,

            CASE
                WHEN pg.granter_service = 'GlobalCard'
                    THEN pu.source_center || 'cc' || pu.source_id || 'cc' || pu.source_subid
                WHEN pg.granter_service = 'GlobalSubscription'
                    THEN pu.source_center || 'ss' || pu.source_id
                WHEN pg.granter_service = 'Addon'
                    THEN '' || pu.source_id
                WHEN pg.granter_service = 'ReceiverGroup' AND rg.rgtype = 'CAMPAIGN'
                    THEN 'C_' || pu.source_id
                WHEN pg.granter_service = 'ReceiverGroup' AND rg.rgtype = 'UNLIMITED'
                    THEN 'TG_' || pu.source_id
                WHEN pg.granter_service = 'StartupCampaign'
                    THEN 'SC_' || pg.granter_id
                WHEN pg.granter_service = 'CompanyAgreement'
                    THEN pg.granter_center || 'p' || pg.granter_id || 'rpt' || pg.granter_subid
                WHEN pg.granter_service = 'Access product'
                    THEN pu.source_center || 'inv' || pu.source_id || 'ln' || pu.source_subid
                ELSE NULL
            END AS priv_source_id,

            ps.name AS priv_set_name,

            CASE
                WHEN pg.granter_service = 'GlobalCard' THEN cc.name
                WHEN pg.granter_service = 'GlobalSubscription' THEN spr.name
                WHEN pg.granter_service = 'Addon' THEN ampr.cached_productname
                WHEN pg.granter_service = 'ReceiverGroup' THEN rg.name
                WHEN pg.granter_service = 'CompanyAgreement'
                    THEN pg.granter_center || 'p' || pg.granter_id || 'rpt' || pg.granter_subid
                WHEN pg.granter_service = 'Access product' THEN appr.name
                ELSE NULL
            END AS priv_source_name,

            prod.center AS prod_center

        FROM invoicelines invl
        CROSS JOIN params
        JOIN invoices inv
            ON invl.center = inv.center AND invl.id = inv.id
        LEFT JOIN fw.persons p
            ON p.center = inv.payer_center AND p.id = inv.payer_id
        JOIN fw.centers c ON c.id = invl.center
        LEFT JOIN center_ext_attrs cea
            ON c.id = cea.center_id AND cea.name = 'Region'
        JOIN fw.products prod
            ON prod.id = invl.productid AND prod.center = invl.productcenter

        LEFT JOIN fw.masterproductregister mpr
            ON mpr.globalid = prod.globalid

        JOIN fw.product_group productGroup
            ON prod.primary_product_group_id = productGroup.id
        LEFT JOIN fw.employees staff
            ON inv.employee_center = staff.center AND inv.employee_id = staff.id
        LEFT JOIN fw.persons staffp
            ON staff.personcenter = staffp.center AND staff.personid = staffp.id
        LEFT JOIN cashregisters cr
            ON inv.cashregister_center = cr.center AND inv.cashregister_id = cr.id
        LEFT JOIN privilege_usages pu
            ON pu.target_service = 'InvoiceLine'
           AND pu.target_center = invl.center
           AND pu.target_id = invl.id
           AND pu.target_subid = invl.subid
        LEFT JOIN privilege_grants pg ON pg.id = pu.grant_id
        LEFT JOIN privilege_receiver_groups rg
            ON pg.granter_service = 'ReceiverGroup'
           AND rg.id = pu.source_id
        LEFT JOIN fw.privilege_sets ps ON ps.id = pg.privilege_set
        LEFT JOIN fw.products cc
            ON pu.source_center = cc.center
           AND pu.source_id = cc.id
           AND pg.granter_service = 'GlobalCard'
        LEFT JOIN fw.subscriptions s
            ON s.center = pu.source_center
           AND s.id = pu.source_id
           AND pg.granter_service = 'GlobalSubscription'
        LEFT JOIN fw.products spr
            ON spr.center = s.subscriptiontype_center
           AND spr.id = s.subscriptiontype_id
        LEFT JOIN fw.subscription_addon sa
            ON sa.id = pu.source_id
           AND pg.granter_service = 'Addon'
        LEFT JOIN fw.masterproductregister ampr
            ON ampr.id = sa.addon_product_id
        LEFT JOIN fw.invoice_lines_mt il
            ON il.center = pu.source_center
           AND il.id = pu.source_id
           AND il.subid = pu.source_subid
           AND pg.granter_service = 'Access product'
        LEFT JOIN fw.products appr
            ON appr.center = il.productcenter
           AND appr.id = il.productid

        WHERE
            inv.trans_time >= params.FromDate
            AND inv.trans_time <= params.ToDate
            AND inv.center IN ($$scope$$)
            AND NOT EXISTS (
                SELECT 1
                FROM fw.credit_note_lines cnl
                WHERE cnl.invoiceline_center = invl.center
                  AND cnl.invoiceline_id = invl.id
                  AND cnl.invoiceline_subid = invl.subid
            )
            AND prod.ptype = 1
        GROUP BY
            c.id, cea.txt_value, p.sex,
            months_between(TRUNC(CURRENT_TIMESTAMP), p.birthdate) / 12,
            p.birthdate, prod.name, prod.globalid, prod.price, prod.cost_price,
            inv.employee_center, inv.employee_id, staffp.fullname,
            p.persontype, productGroup.name, p.center, p.id, p.external_id,
            payer_id, p.firstname, p.lastname, prod.ptype,
            TO_CHAR(longtodate(inv.trans_time),'yyyy-MM-dd'),
            TO_CHAR(longtodate(inv.trans_time),'HH24:MI'), cr.name,
            pg.granter_service, rg.rgtype, pu.source_center,
            pu.source_id, pu.source_subid, pg.granter_id,
            pg.granter_center, prod.center, pg.granter_subid,
            ps.name, cc.name, spr.name, rg.name, appr.name,
            ampr.cached_productname, mpr.cached_external_id
        ORDER BY prod.globalid
    )

SELECT
    t2.id,
    t2.region,
    t2.product_group_name,
    t2.payer_id,
    t2.external_id,
    t2.master_cached_external_id,          
    t2.sex,
    t2.age,
    t2.birthdate,
    t2.payer_name,
    t2."Person Type",
    t2.product,
    t2.product_name,
    t2.product_type,
    t2.sold_units,
    CAST((t2.ph_normal_price::text) AS DECIMAL) AS normal_price,
    CAST((t2.ph_cost_price::text) AS DECIMAL) AS cost_price,
    t2.amount_excl_vat,
    t2.amount_incl_vat,
    t2.staff,
    t2.staff_name,
    t2."Invoice Date",
    t2."Invoice Time",
    t2.cashregister,
    t2.priv_source_type AS "Privilege Source Type",
    t2.priv_source_id AS "Privilege Source ID",
    t2.priv_set_name AS "Privilege Set Name",
    t2.priv_source_name AS "Privilege Source Name"
FROM (
    SELECT *
    FROM (
        SELECT
            ep.*,
            RANK() OVER (
                PARTITION BY ep.payer_id, ep.product, ep."Invoice Date", ep."Invoice Time"
                ORDER BY st.level, CAST(ph.start_date::text AS DATE) DESC
            ) AS rnk,
            ph.normal_price AS ph_normal_price,
            ph.cost_price AS ph_cost_price
        FROM eligible_products ep
        JOIN price_history ph
            ON ph.globalid = ep.product
           AND CAST(ep."Invoice Date" AS DATE) > CAST(ph.start_date::text AS DATE)
        JOIN scope_tree st
            ON ep.prod_center = st.center_id
           AND ph.mpr_scope_type = st.scope_type
           AND ph.mpr_scope_id = st.scope_id
    ) t1
    WHERE t1.rnk = 1
) t2
ORDER BY t2.product, t2.id, t2.region, t2.age;
