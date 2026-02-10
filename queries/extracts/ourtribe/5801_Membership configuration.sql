-- The extract is extracted from Exerp on 2026-02-08
--  
WITH master_product_table AS
(
        SELECT
                mpr.globalid,
                mpli.master_product_id,
                mpg.name
        FROM master_prod_and_prod_grp_link mpli
        JOIN product_group mpg ON mpli.product_group_id = mpg.id
        JOIN masterproductregister mpr ON mpr.id = mpli.master_product_id
        WHERE
                mpli.product_group_id != mpr.primary_product_group_id
        ORDER BY
                mpli.master_product_id,
                mpg.name          
),
master_product_table_grouped AS
( 
        SELECT
                mpt.master_product_id,
                STRING_AGG(mpt.name,' ; ') AS secondary_pg
        FROM master_product_table mpt
        GROUP BY
                mpt.master_product_id
),
priv_sets AS 
(
        SELECT
                t2.granter_id,
                STRING_AGG(t2.name,' ; ') list_privset
        FROM
        (
                WITH params AS MATERIALIZED
                (
                        SELECT FLOOR(extract(epoch FROM now())*1000) AS cutDate
                )
                SELECT
                        pg.granter_id,
                        ps.name
                FROM privilege_grants pg
                CROSS JOIN params par
                JOIN privilege_sets ps ON pg.privilege_set = ps.id
                WHERE
                        pg.granter_service = 'GlobalSubscription'
                        AND
                        (
                                pg.valid_from < par.cutDate
                                AND (pg.valid_to IS NULL OR pg.valid_to > par.cutDate)
                        )
                ORDER BY 2
        ) t2
        GROUP BY
                t2.granter_id
),
full_collection AS
(
        SELECT
                ------------------------- SUBSCRIPTION -------------------------
                t1.scope_type,
                t1.scope_id,
                t1.scope_name,
                t1.country,
                t1.state,
                t1.globalid AS global_name,
                t1.cached_productname AS product_name,
                t1.cached_productprice AS product_price,
                t1.show_on_web,
                t1.PrimaryProductGroup,
                sec_pg.secondary_pg AS SecondaryProductGroup,
                t1.Account_configuration,
                ------------------- EXTATTR - BASE SETTINGS --------------------
                t1.rank,
                t1.subscription_type,
                t1.renew_period,
                t1.period_count,
                t1.binding_period,
                t1.ext_binding_prorata,
                t1.prorata_period,
                t1.ext_binding_initial,
                t1.initial_period,
                t1.allow_reactivation_in_window,
                -------------------- EXTATTR - DOC SETTINGS --------------------
                t1.use_contract_template,
                t.description AS template_name,
                ----------------------- EXTATTR - FREEZE -----------------------
                t1.price_during_freeze,
                t1.within_a_period_of,
                t1."within_a_period_of(unit)",
                t1.subscription_can_be_frozen,
                t1.minimum_of,
                t1."minimum_of(unit)",
                t1.maximum_of,
                t1."maximum_of(unit)",
                ---------------------- EXTATTR - JOINING -----------------------
                pgj.NAME AS joining_fee_product_group,
                t1.joining_fee_price,
                t1.joining_fee_show_on_sales,
                t1.joining_fee_accounts,
                ---------------------- EXTATTR - PRORATA -----------------------
                pgpr.NAME AS prorata_product_group,
                t1.prorata_accounts,
                ------------------- EXTATTR - ADMINISTRATOR --------------------
                t1.administration_fee,
                --------------------- EXTATTR - BUYOUTFEE ----------------------
                t1.buyout_fee,
                --------------------- EXTATTR - PRIVILEGES ----------------------
                ps.list_privset AS privilege_sets,
                t1.reassignmentProductID,
                t1.reassignmenttemplate,
                t1.startdatelimitation,
				:Country AS countrySelected
        FROM
        (
                WITH pmp_xml AS 
                (
                        SELECT 
                                m.id, 
                                CAST(convert_from(m.product, 'UTF-8') AS XML) AS pxml 
                        FROM masterproductregister m 
                        WHERE
                                m.state NOT IN ('DELETED')
                                AND m.cached_producttype = 10
                ) 
                SELECT 
                        mpr.id,
                        mpr.scope_type,
                        c.country,
                        (CASE 
                                WHEN mpr.scope_type = 'T' THEN 'System'
                                WHEN mpr.scope_type = 'A' THEN a.name
                                WHEN mpr.scope_type = 'C' THEN c.name
                                ELSE NULL
                        END) AS scope_name,
                        mpr.scope_id,
                        mpr.globalid,
                        mpr.cached_productname,
                        mpr.cached_productprice,
                        UNNEST(xpath('//subscriptionType/@type', px.pxml))::text AS subscription_type,
                        mpr.state,
                        ppg.name AS PrimaryProductGroup,
                        pac1.name AS Account_configuration,
                        mpr.use_contract_template,
                        mpr.contract_template_id,
                        --UNNEST(xpath('//subscriptionType/product/showOnWeb/text()',px.pxml))::text AS show_on_web,
                        UNNEST(xpath('//subscriptionNew/product/showOnWeb/text()',px.pxml))::text AS show_on_web,
                        ------------------------------------------------------------------------------------------------------------------------------
                        UNNEST(xpath('//subscriptionType/rank/text()',px.pxml))::text AS rank,
                        UNNEST(xpath('//subscriptionType/renewWindow/period/text()',px.pxml))::text || ' Days' AS renew_period,
                        UNNEST(xpath('//subscriptionType/billingPeriod/period/text()',px.pxml))::text AS period_count,
                        UNNEST(xpath('//subscriptionType/billingPeriod/period/@unit',px.pxml))::text AS "period_count(unit)",
                        UNNEST(xpath('//subscriptionType/bindingPeriod/period/text()',px.pxml))::text AS binding_period,
                        UNNEST(xpath('//subscriptionType/prorataPeriod/bindingExtend/text()',px.pxml))::text AS ext_binding_prorata,
                        UNNEST(xpath('//subscriptionType/prorataPeriod/period/text()',px.pxml))::text AS prorata_period,
                        UNNEST(xpath('//subscriptionType/initialPeriod/bindingExtend/text()',px.pxml))::text AS ext_binding_initial,
                        UNNEST(xpath('//subscriptionType/initialPeriod/period/text()',px.pxml))::text AS initial_period,
                        ------------------------------------------------------------------------------------------------------------------------------
                        UNNEST(xpath('//subscriptionType/freeze/period/product/prices/price/normalPrice/text()',px.pxml))::text AS price_during_freeze,
                        UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/FREEZEAPPLYPERIOD/FREEZEDURATION/@LENGTH', px.pxml))::text AS within_a_period_of,
                        UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/FREEZEAPPLYPERIOD/FREEZEDURATION/@UNIT', px.pxml))::text AS "within_a_period_of(unit)",
                        UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MAXFREEZES', px.pxml))::text AS subscription_can_be_frozen,
                        UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MINDURATION', px.pxml))::text AS minimum_of,
                        UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MINDURATION_UNIT', px.pxml))::text AS "minimum_of(unit)",
                        UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MAXDURATION', px.pxml))::text AS maximum_of,
                        UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MAXDURATION_UNIT', px.pxml))::text AS "maximum_of(unit)",
                        ------------------------------------------------------------------------------------------------------------------------------
                        UNNEST(xpath('//subscriptionType/subscriptionNew/product/primaryProductGroupKey/text()', px.pxml))::text AS joining_pg_key,
                        UNNEST(xpath('//subscriptionType/subscriptionNew/product/prices/price/normalPrice/text()', px.pxml))::text AS joining_fee_price,
                        UNNEST(xpath('//subscriptionType/subscriptionNew/product/showInSale/text()',px.pxml))::text AS joining_fee_show_on_sales,
                        UNNEST(xpath('//reassignConfig/productId/text()',px.pxml))::text AS reassignmentProductID,
                        UNNEST(xpath('//reassignConfig/templateKey/text()',px.pxml))::text AS reassignmenttemplate,
                        UNNEST(xpath('//startDateLimitation/period/text()',px.pxml))::text AS startdatelimitation,
                        pac2.name AS joining_fee_accounts,
                        ------------------------------------------------------------------------------------------------------------------------------
                        UNNEST(xpath('//subscriptionType/subscriptionProRataPeriod/product/primaryProductGroupKey/text()', px.pxml))::text AS prorata_pg_key,
                        pac3.name AS prorata_accounts,
                        ------------------------------------------------------------------------------------------------------------------------------
                        UNNEST(xpath('//subscriptionType/reactivationAllowed/text()', px.pxml))::text AS allow_reactivation_in_window,
                        adf.globalid AS administration_fee,
                        buf.globalid AS buyout_fee,
                        mpr.product
                FROM pmp_xml px
                JOIN masterproductregister mpr ON mpr.id = px.id
                LEFT JOIN product_group ppg ON mpr.primary_product_group_id = ppg.id
                LEFT JOIN areas a ON a.id = mpr.scope_id AND mpr.scope_type = 'A'
                LEFT JOIN centers c ON c.id = mpr.scope_id AND mpr.scope_type = 'C'
                LEFT JOIN masterproductregister buf ON buf.id = mpr.buyout_fee_config_id
                LEFT JOIN product_account_configurations pac1 ON pac1.id = mpr.product_account_config_id
                LEFT JOIN product_account_configurations pac2 ON pac2.id = mpr.creation_account_config_id
                LEFT JOIN product_account_configurations pac3 ON pac3.id = mpr.prorata_account_config_id
                LEFT JOIN masterproductregister adf ON adf.id = mpr.admin_fee_config_id
                ORDER BY mpr.globalid, 1 DESC
        ) t1
        LEFT JOIN product_group pgj ON pgj.id = CAST(t1.joining_pg_key AS INT)
        LEFT JOIN product_group pgpr ON pgpr.id = CAST(t1.prorata_pg_key AS INT)
        LEFT JOIN master_product_table_grouped sec_pg ON sec_pg.master_product_id = t1.id
        LEFT JOIN priv_sets ps ON ps.granter_id = t1.id
        LEFT JOIN templates t ON t.id = t1.contract_template_id
)
SELECT fc.*
FROM full_collection fc
