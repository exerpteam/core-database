with philippines_products AS
(
        SELECT
                mpr_top.id,
                mpr_top.definition_key,
                mpr_top.globalid,
                mpr_top.cached_productname,
                mpr_top.state,
                mpr_top.scope_type,
                mpr_top.scope_id,
                (CASE WHEN 
                        mpr_ph.id IS NOT NULL THEN 'YES'
                        ELSE NULL
                END) override_philippines,
                (CASE WHEN 
                        mpr_ph_ff.id IS NOT NULL THEN 'YES'
                        ELSE NULL
                END) override_fitnessFirst,
                (CASE WHEN 
                        mpr_ph_plat.id IS NOT NULL THEN 'YES'
                        ELSE NULL
                END) override_platinum,
                (CASE WHEN 
                        mpr_ph_blue.id IS NOT NULL THEN 'YES'
                        ELSE NULL
                END) override_blue
        FROM evolutionwellness.masterproductregister mpr_top
        LEFT JOIN evolutionwellness.masterproductregister mpr_ph ON mpr_top.globalid = mpr_ph.globalid AND mpr_ph.scope_type = 'A' AND mpr_ph.scope_id = 40
        LEFT JOIN evolutionwellness.masterproductregister mpr_ph_ff ON mpr_top.globalid = mpr_ph_ff.globalid AND mpr_ph_ff.scope_type = 'A' AND mpr_ph_ff.scope_id = 18
        LEFT JOIN evolutionwellness.masterproductregister mpr_ph_plat ON mpr_top.globalid = mpr_ph_plat.globalid AND mpr_ph_plat.scope_type = 'A' AND mpr_ph_plat.scope_id = 24
        LEFT JOIN evolutionwellness.masterproductregister mpr_ph_blue ON mpr_top.globalid = mpr_ph_blue.globalid AND mpr_ph_blue.scope_type = 'A' AND mpr_ph_blue.scope_id = 25
        WHERE
                mpr_top.cached_producttype = 10
                AND mpr_top.id = mpr_top.definition_key
                AND mpr_top.state NOT IN ('DELETED')
                AND (mpr_top.scope_type, mpr_top.scope_id) NOT IN (('A',13),('A',19))
                AND 
                (
                        mpr_ph.id IS NOT NULL
                        OR
                        mpr_ph_ff.id IS NOT NULL
                        OR
                        mpr_ph_plat.id IS NOT NULL
                        OR
                        mpr_ph_blue.id IS NOT NULL
                )
), 
pmp_xml AS 
(
        SELECT 
                m.id, 
                CAST(convert_from(m.product, 'UTF-8') AS XML) AS pxml 
        FROM philippines_products pp
        JOIN masterproductregister m ON pp.globalid = m.globalid
        WHERE
                m.scope_type NOT IN ('T','C')
                AND (m.scope_type, m.scope_id) NOT IN (('A',23),('A',15),('A',2),('A',4),('A',7),('A',17),('A',19),('A',22),('A',34),('A',38),('A',33),('A',6),('A',8),('A',9),('A',13),('A',14),('A',21))
)
SELECT
        ps.name,
        longtodate(pg.valid_to),
        t1.*,
        (CASE
                WHEN t1.freeze_free_product = 'SERV00000012' THEN 'Freeze Fee'
                WHEN t1.freeze_free_product = 'SERV00000027' THEN 'Freeze Fee SC/PWD'
                ELSE NULL
        END) AS freezeproduct
FROM
(
        SELECT
                --px.pxml,
                mpr.id,
                mpr.definition_key,
                mpr.globalid,
                mpr.cached_productname,
                mpr.state,
                mpr.scope_type,
                mpr.scope_id,
                mpr.use_contract_template,
                mpr.contract_template_id,
                t.description AS contract_template_name,
                UNNEST(xpath('//subscriptionType/@type', px.pxml))::text AS subscription_type,
                UNNEST(xpath('//subscriptionType/renewWindow/period/text()',px.pxml))::text || ' Days' AS renew_period,
                UNNEST(xpath('//subscriptionType/billingPeriod/period/text()',px.pxml))::text AS period_count,
                UNNEST(xpath('//subscriptionType/billingPeriod/period/@unit',px.pxml))::text AS "period_count(unit)",
                UNNEST(xpath('//subscriptionType/bindingPeriod/period/text()',px.pxml))::text AS binding_period,
                UNNEST(xpath('//subscriptionType/prorataPeriod/bindingExtend/text()',px.pxml))::text AS ext_binding_prorata,
                UNNEST(xpath('//subscriptionType/prorataPeriod/period/text()',px.pxml))::text AS prorata_period,
                UNNEST(xpath('//subscriptionType/initialPeriod/bindingExtend/text()',px.pxml))::text AS ext_binding_initial,
                UNNEST(xpath('//subscriptionType/initialPeriod/period/text()',px.pxml))::text AS initial_period,
                UNNEST(xpath('//startDateLimitation/period/text()',px.pxml))::text AS startdatelimitation,
                UNNEST(xpath('//subscriptionType/reactivationAllowed/text()', px.pxml))::text AS allow_reactivation_in_window,
                UNNEST(xpath('//subscriptionType/freeze/period/product/prices/price/normalPrice/text()',px.pxml))::text AS price_during_freeze,
                UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/FREEZEAPPLYPERIOD/FREEZEDURATION/@LENGTH', px.pxml))::text AS within_a_period_of,
                UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/FREEZEAPPLYPERIOD/FREEZEDURATION/@UNIT', px.pxml))::text AS "within_a_period_of(unit)",
                UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MAXFREEZES', px.pxml))::text AS subscription_can_be_frozen,
                UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MINDURATION', px.pxml))::text AS minimum_of,
                UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MINDURATION_UNIT', px.pxml))::text AS "minimum_of(unit)",
                UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MAXDURATION', px.pxml))::text AS maximum_of,
                UNNEST(xpath('//subscriptionType/freeze/FREEZELIMIT/@MAXDURATION_UNIT', px.pxml))::text AS "maximum_of(unit)",
                UNNEST(xpath('//subscriptionType/freeze/start/product/globalId/text()', px.pxml))::text AS freeze_free_product,
                
                UNNEST(xpath('//subscriptionType/subscriptionNew/product/primaryProductGroupKey/text()', px.pxml))::text AS joining_pg_key,
                UNNEST(xpath('//subscriptionType/subscriptionNew/product/prices/price/normalPrice/text()', px.pxml))::text AS joining_fee_price,
                UNNEST(xpath('//subscriptionType/subscriptionNew/product/showInSale/text()',px.pxml))::text AS joining_fee_show_on_sales,
                UNNEST(xpath('//reassignConfig/productId/text()',px.pxml))::text AS reassignmentProductID,
                UNNEST(xpath('//reassignConfig/templateKey/text()',px.pxml))::text AS reassignmenttemplate,
                UNNEST(xpath('//startDateLimitation/period/text()',px.pxml))::text AS startdatelimitation,
                pac1.name AS subscription_accounts,
                pac2.name AS joining_fee_accounts,
                UNNEST(xpath('//subscriptionType/subscriptionProRataPeriod/product/primaryProductGroupKey/text()', px.pxml))::text AS prorata_pg_key,
                pac3.name AS prorata_accounts,
                UNNEST(xpath('//subscriptionType/reactivationAllowed/text()', px.pxml))::text AS allow_reactivation_in_window,
                adf.globalid AS administration_fee,
                buf.globalid AS buyout_fee
        FROM pmp_xml px
        JOIN masterproductregister mpr ON mpr.id = px.id
        LEFT JOIN evolutionwellness.templates t ON t.id = mpr.contract_template_id
        LEFT JOIN evolutionwellness.product_account_configurations pac1 ON pac1.id = mpr.product_account_config_id
        LEFT JOIN evolutionwellness.product_account_configurations pac2 ON pac2.id = mpr.creation_account_config_id
        LEFT JOIN evolutionwellness.product_account_configurations pac3 ON pac3.id = mpr.prorata_account_config_id
        LEFT JOIN evolutionwellness.masterproductregister adf ON adf.id = mpr.admin_fee_config_id
        LEFT JOIN evolutionwellness.masterproductregister buf ON buf.id = mpr.buyout_fee_config_id
) t1
LEFT JOIN evolutionwellness.privilege_grants pg ON t1.id  = pg.granter_id AND pg.granter_service = 'GlobalSubscription'
LEFT JOIN evolutionwellness.privilege_sets ps ON pg.privilege_set = ps.id
WHERE
        t1.cached_productname LIKE '%Complimentary%'