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
    t2.globalid,
    t2.subscription_name,
    t2.subtype,
    t2.period_unit,
    t2.period,
    t2.price,
    t2.needs_privilege,
    t2.req_role AS required_role,
    t2.show_in_sale,
    t2.returnable,
    t2.show_on_web,
    t2.show_on_mobile_api,
    t2.primary_product_group,
    t2.product_groups,
    t2.product_account_config,
    t2.prorata_period,
    t2.prorata_primary_product_group,
    t2.prorata_product_groups,
    t2.prorata_product_account_config,
    t2.joiningfee_primary_product_group,
    t2.joiningfee_product_groups,
    t2.joiningfee_product_account_config,
    t2.initialperiod,
    t2.binding_period,
    t2.extend_binding_period,
    t2.window_period,
    t2.rank,
    t2.price_update_excluded,
    t2.start_date_restriction
FROM
    (
        SELECT
            t1.*,
            pg_primary_jf.name                    AS joiningfee_primary_product_group,
            STRING_AGG(DISTINCT pg_jf.name, '::')  AS joiningfee_product_groups,
            pac_jf.name                            AS joiningfee_product_account_config,
            pg_primary_pro.name                    AS prorata_primary_product_group,
            STRING_AGG(DISTINCT pg_pro.name, '::') AS prorata_product_groups,
            pac_pro.name                           AS prorata_product_account_config,
            r.rolename                             AS req_role
        FROM
            (
                SELECT
                    pr.center AS prod_center,
                    pr.name   AS subscription_name,
                    pr.price,
                    pr.needs_privilege,
                    pr.show_in_sale,
                    pr.returnable,
                    pr.show_on_web,
                    pr.show_on_mobile_api,
                    pg_primary.name                    AS primary_product_group,
                    STRING_AGG(DISTINCT pg.name, '::') AS product_groups,
                    pac.name                           AS product_account_config,
                    product.*
                FROM
                    (
                        SELECT
                            mpr.globalid,
                            mpr.id AS mpr_id,
                            CAST(UNNEST(xpath('//subscriptionType/@type', pmp_xml.pxml)) AS VARCHAR
                            (100)) AS subType,
                            CAST(UNNEST(xpath('//subscriptionType/billingPeriod/period/@unit',
                            pmp_xml.pxml )) AS VARCHAR(100)) AS period_unit,
                            CAST(UNNEST(xpath('//subscriptionType/billingPeriod/period/text()',
                            pmp_xml.pxml)) AS VARCHAR(100)) AS period,
                            CAST(UNNEST(xpath('//subscriptionType/prorataPeriod/period/text()',
                            pmp_xml.pxml)) AS VARCHAR(100)) AS prorata_period,
                            CAST(UNNEST(xpath('//subscriptionType/initialPeriod/period/text()',
                            pmp_xml.pxml)) AS VARCHAR(100)) AS initialperiod,
                            CAST(UNNEST(xpath('//subscriptionType/bindingPeriod/period/text()',
                            pmp_xml.pxml)) AS VARCHAR(100)) AS binding_period,
                            CAST(UNNEST(xpath
                            ('//subscriptionType/initialPeriod/bindingExtend/text()', pmp_xml.pxml
                            )) AS VARCHAR(100)) AS extend_binding_period,
                            CAST(UNNEST(xpath('//subscriptionType/renewWindow/period/text()',
                            pmp_xml.pxml) ) AS VARCHAR(100)) AS window_period,
                            CAST(UNNEST(xpath('//subscriptionType/rank/text()', pmp_xml.pxml)) AS
                            VARCHAR (100)) AS rank,
                            CAST(UNNEST(xpath('//subscriptionType/priceUpdateExcluded/text()',
                            pmp_xml.pxml )) AS VARCHAR(100)) AS price_update_excluded,
                            CAST(UNNEST(xpath('//subscriptionType/startDateRestriction/text()',
                            pmp_xml.pxml)) AS VARCHAR(100)) AS start_date_restriction,
                            CAST(CAST(UNNEST(xpath
                            ('//subscriptionType/subscriptionNew/product/requiredRole/text()',
                            pmp_xml.pxml )) AS VARCHAR(100)) AS INT) AS required_role,
                            CAST(UNNEST(xpath
                            ('//subscriptionType/subscriptionNew/product/globalId/text()',
                            pmp_xml.pxml)) AS VARCHAR(100)) AS Joiningfee_globalid,
                            CAST(UNNEST(xpath
                            ('//subscriptionType/subscriptionProRataPeriod/product/globalId/text()'
                            , pmp_xml.pxml)) AS VARCHAR(100)) AS Prorata_globalid
                        FROM
                            pmp_xml,
                            masterproductregister mpr
                        WHERE
                            mpr.id = pmp_xml.id
                        AND mpr.cached_producttype = 10) product
                JOIN
                    products pr
                ON
                    pr.globalid = product.globalid
                JOIN
                    subscriptiontypes st
                ON
                    st.center = pr.center
                AND st.id = pr.id
                JOIN
                    product_and_product_group_link ppgl
                ON
                    ppgl.product_center = pr.center
                AND ppgl.product_id = pr.id
                JOIN
                    product_group pg
                ON
                    pg.id = ppgl.product_group_id
                AND pg.state = 'ACTIVE'
                JOIN
                    product_account_configurations pac
                ON
                    pac.id = pr.product_account_config_id
                JOIN
                    product_group pg_primary
                ON
                    pg_primary.id = pr.primary_product_group_id
                GROUP BY
                    pr.center,
                    pr.name,
                    pr.price,
                    pr.needs_privilege,
                    pr.show_in_sale,
                    pr.returnable,
                    pr.show_on_web,
                    pr.show_on_mobile_api,
                    pg_primary.name,
                    pac.name,
                    product.globalid,
                    product.mpr_id,
                    product.subtype,
                    product.period_unit,
                    product.period,
                    product.prorata_period,
                    product.initialperiod,
                    product.binding_period,
                    product.extend_binding_period,
                    product.window_period,
                    product.rank,
                    product.price_update_excluded,
                    product.start_date_restriction,
                    product.required_role,
                    product.joiningfee_globalid,
                    product.prorata_globalid) t1
        LEFT JOIN
            products jf
        ON
            jf.globalid = t1.joiningfee_globalid
        AND jf.center = t1.prod_center
        LEFT JOIN
            product_and_product_group_link ppgl_jf
        ON
            ppgl_jf.product_center = jf.center
        AND ppgl_jf.product_id = jf.id
        LEFT JOIN
            product_group pg_jf
        ON
            pg_jf.id = ppgl_jf.product_group_id
        AND pg_jf.state = 'ACTIVE'
        LEFT JOIN
            product_account_configurations pac_jf
        ON
            pac_jf.id = jf.product_account_config_id
        LEFT JOIN
            product_group pg_primary_jf
        ON
            pg_primary_jf.id = jf.primary_product_group_id
        LEFT JOIN
            products pro
        ON
            pro.globalid = t1.joiningfee_globalid
        AND pro.center = t1.prod_center
        LEFT JOIN
            product_and_product_group_link ppgl_pro
        ON
            ppgl_pro.product_center = pro.center
        AND ppgl_pro.product_id = pro.id
        LEFT JOIN
            product_group pg_pro
        ON
            pg_pro.id = ppgl_pro.product_group_id
        AND pg_pro.state = 'ACTIVE'
        LEFT JOIN
            product_account_configurations pac_pro
        ON
            pac_pro.id = pro.product_account_config_id
        LEFT JOIN
            product_group pg_primary_pro
        ON
            pg_primary_pro.id = pro.primary_product_group_id
        LEFT JOIN
            roles r
        ON
            r.id = t1.required_role
        GROUP BY
            t1.prod_center,
            t1.subscription_name,
            t1.price,
            t1.needs_privilege,
            t1.show_in_sale,
            t1.returnable,
            t1.show_on_web,
            t1.show_on_mobile_api,
            t1.primary_product_group,
            t1.product_groups,
            t1.product_account_config,
            t1.globalid,
            t1.mpr_id,
            t1.subtype,
            t1.period_unit,
            t1.period,
            t1.prorata_period,
            t1.initialperiod,
            t1.binding_period,
            t1.extend_binding_period,
            t1.window_period,
            t1.rank,
            t1.price_update_excluded,
            t1.start_date_restriction,
            t1.required_role,
            t1.joiningfee_globalid,
            t1.prorata_globalid,
            pg_primary_jf.name,
            pac_jf.name,
            pg_primary_pro.name,
            pac_pro.name,
            r.rolename ) t2
GROUP BY
    t2.globalid,
    t2.subscription_name,
    t2.subtype,
    t2.period_unit,
    t2.period,
    t2.price,
    t2.needs_privilege,
    t2.req_role,
    t2.show_in_sale,
    t2.returnable,
    t2.show_on_web,
    t2.show_on_mobile_api,
    t2.primary_product_group,
    t2.product_groups,
    t2.product_account_config,
    t2.prorata_period,
    t2.prorata_primary_product_group,
    t2.prorata_product_groups,
    t2.prorata_product_account_config,
    t2.joiningfee_primary_product_group,
    t2.joiningfee_product_groups,
    t2.joiningfee_product_account_config,
    t2.initialperiod,
    t2.binding_period,
    t2.extend_binding_period,
    t2.window_period,
    t2.rank,
    t2.price_update_excluded,
    t2.start_date_restriction
ORDER BY
    t2.subscription_name