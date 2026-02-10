-- The extract is extracted from Exerp on 2026-02-08
-- Used to pull a full set of data for the product audit baseline product and any audit result products
SELECT DISTINCT
    -------------------------------
    -------for subscription product
    p1.center                       AS p_center,
    p1.id                           AS p_id,
    p1.ptype                        AS p_ptype,
    p1.name                         AS p_Product_name,
    p1.coment                       AS p_coment,
    p1.external_id                  AS p_external_id,
    p1.income_accountcenter         AS p_income_accountcenter,
    p1.income_accountid             AS p_income_accountid,
    p1.expense_accountcenter        AS p_expense_accountcenter,
    p1.expense_accountid            AS p_expense_accountid,
    p1.refund_accountcenter         AS p_refund_accountcenter,
    p1.refund_accountid             AS p_refund_accountid,
    p1.price                        AS p_price,
    p1.min_price                    AS p_min_price,
    p1.cost_price                   AS p_cost_price,
    p1.requiredrole                 AS p_requiredrole,
    p1.globalid                     AS p_globalid,
    p1.max_buy_qty                  AS p_max_buy_qty,
    p1.max_buy_qty_period           AS p_max_buy_qty_period,
    p1.max_buy_qty_period_type      AS p_max_buy_qty_period_type,
    p1.needs_privilege              AS p_needs_privilege,
    p1.show_in_sale                 AS p_show_in_sale,
    p1.returnable                   AS p_returnable,
    p1.show_on_web                  AS p_show_on_web,
    p1.primary_product_group_id     AS p_primary_product_group_id,
    p1.product_account_config_id    AS p_product_account_config_id,
    p1.override_price_and_text_role AS p_override_price_and_text_role,
    p1.ipc_available                AS p_ipc_available,
    p1.restriction_type             AS p_restriction_type,
    p1.mapi_selling_points          AS p_mapi_selling_points,
    p1.mapi_rank                    AS p_mapi_rank,
    --          --mapi_description not included as it's written text description
    p1.sales_commission         AS p_sales_commission,
    p1.sales_units              AS p_sales_units,
    p1.period_commission        AS p_period_commission,
    p1.sold_outside_home_center AS p_sold_outside_home_center,
    p1.show_on_mobile_api       AS p_show_on_mobile_api,
    p1.assigned_staff_group     AS p_assigned_staff_group,
    p1.print_qr_on_receipt      AS p_print_qr_on_receipt,
    p1.last_recount_date        AS p_last_recount_date,
    p1.single_use               AS p_single_use,
    p1.flat_rate_commission     AS p_flat_rate_commission,
    p1.webname                  AS p_webname,
    -------------------------------
    -------for product_group table
    pg1.id                            AS pg_id,
    pg1.top_node_id                   AS pg_top_node_id,
    pg1.scope_type                    AS pg_scope_type,
    pg1.scope_id                      AS pg_scope_id,
    pg1.name                          AS pg_name,
    pg1.state                         AS pg_state,
    pg1.parent_product_group_id       AS pg_parent_product_group_id,
    pg1.show_in_shop                  AS pg_show_in_shop,
    pg1.product_account_config_id     AS pg_product_account_config_id,
    pg1.colour_group_id               AS pg_colour_group_id,
    pg1.ranking                       AS pg_ranking,
    pg1.in_subscription_sales         AS pg_in_subscription_sales,
    pg1.hide_in_report_parameters     AS pg_hide_in_report_parameters,
    pg1.exclude_from_member_count     AS pg_exclude_from_member_count,
    pg1.exclude_from_product_cleaning AS pg_exclude_from_product_cleaning ,
    pg1.client_profile_id             AS pg_client_profile_id,
    pg1.external_id                   AS pg_external_id,
    pg1.single_product_in_basket      AS pg_single_product_in_basket,
    pg1.dimension_product_group_id    AS pg_dimension_product_group_id,
    -------------------------------
    -------for subscriptiontypes table
    st1.center                         AS st_center,
    st1.id                             AS st_id,
    st1.st_type                        AS st_st_type,
    st1.use_individual_price           AS st_use_individual_price,
    st1.floatingperiod                 AS st_floatingperiod,
    st1.prorataperiodcount             AS st_prorataperiodcount,
    st1.extend_binding_by_prorata      AS st_extend_binding_by_prorata,
    st1.initialperiodcount             AS st_initialperiodcount,
    st1.extend_binding_by_initial      AS st_extend_binding_by_initial,
    st1.bindingperiodcount             AS st_bindingperiodcount,
    st1.periodunit                     AS st_periodunit,
    st1.periodcount                    AS st_periodcount,
    st1.age_restriction_type           AS st_age_restriction_type,
    st1.age_restriction_value          AS st_age_restriction_value,
    st1.sex_restriction                AS st_sex_restriction,
    st1.freezeperiodproduct_center     AS st_freezeperiodproduct_center,
    st1.freezestartupproduct_center    AS st_freezestartupproduct_center,
    st1.transferproduct_center         AS st_transferproduct_center,
    st1.add_on_to_center               AS st_add_on_to_center,
    st1.renew_window                   AS st_renew_window,
    st1.rank                           AS st_rank,
    st1.is_addon_subscription          AS st_is_addon_subscription,
    st1.prorataproduct_center          AS st_prorataproduct_center,
    st1.adminfeeproduct_center         AS st_adminfeeproduct_center,
    st1.clearing_house_restriction     AS st_clearing_house_restriction,
    st1.is_price_update_excluded       AS st_is_price_update_excluded,
    st1.start_date_limit_count         AS st_start_date_limit_count,
    st1.start_date_limit_unit          AS st_start_date_limit_unit,
    st1.start_date_restriction         AS st_start_date_restriction,
    st1.auto_stop_on_binding_end_date  AS st_auto_stop_on_binding_end_date,
    st1.roundup_end_unit               AS st_roundup_end_unit,
    st1.buyoutfeeproduct_center        AS st_buyoutfeeproduct_center,
    st1.rec_clipcard_product_center    AS st_rec_clipcard_product_center,
    st1.autorenew_binding_count        AS st_autorenew_binding_count,
    st1.autorenew_binding_unit         AS st_autorenew_binding_unit,
    st1.autorenew_binding_notice_count AS st_autorenew_binding_notice_count,
    st1.autorenew_binding_notice_unit  AS st_autorenew_binding_notice_unit,
    st1.sale_startup_clipcard          AS st_sale_startup_clipcard,
    st1.unrestricted_freeze_allowed    AS st_unrestricted_freeze_allowed,
    st1.buyout_fee_percentage          AS st_buyout_fee_percentage,
    st1.change_requiredrole            AS st_change_requiredrole,
    st1.reactivation_allowed           AS st_reactivation_allowed,
    st1.can_be_reassigned              AS st_can_be_reassigned,
    st1.rec_clipcard_pack_size         AS st_rec_clipcard_pack_size,
    -------------------------------
    -------for clipcard products for recurring subscription
    rec_ccp1.center                       AS rec_ccp1_center,
    rec_ccp1.id                           AS rec_ccp1_id,
    rec_ccp1.ptype                        AS rec_ccp_ptype,
    rec_ccp1.external_id                  AS rec_ccp_external_id,
    rec_ccp1.income_accountcenter         AS rec_ccp_income_accountcenter,
    rec_ccp1.income_accountid             AS rec_ccp_income_accountid,
    rec_ccp1.expense_accountcenter        AS rec_ccp_expense_accountcenter,
    rec_ccp1.expense_accountid            AS rec_ccp_expense_accountid,
    rec_ccp1.refund_accountcenter         AS rec_ccp_refund_accountcenter,
    rec_ccp1.refund_accountid             AS rec_ccp_refund_accountid,
    rec_ccp1.price                        AS rec_ccp_price,
    rec_ccp1.min_price                    AS rec_ccp_min_price,
    rec_ccp1.cost_price                   AS rec_ccp_cost_price,
    rec_ccp1.requiredrole                 AS rec_ccp_requiredrole,
    rec_ccp1.globalid                     AS rec_ccp_globalid,
    rec_ccp1.max_buy_qty                  AS rec_ccp_max_buy_qty,
    rec_ccp1.max_buy_qty_period           AS rec_ccp_max_buy_qty_period,
    rec_ccp1.max_buy_qty_period_type      AS rec_ccp_max_buy_qty_period_type,
    rec_ccp1.needs_privilege              AS rec_ccp_needs_privilege,
    rec_ccp1.show_in_sale                 AS rec_ccp_show_in_sale,
    rec_ccp1.returnable                   AS rec_ccp_returnable,
    rec_ccp1.show_on_web                  AS rec_ccp_show_on_web,
    rec_ccp1.primary_product_group_id     AS rec_ccp_primary_product_group_id,
    rec_ccp1.product_account_config_id    AS rec_ccp_product_account_config_id,
    rec_ccp1.override_price_and_text_role AS rec_ccp_override_price_and_text_role,
    rec_ccp1.ipc_available                AS rec_ccp_ipc_available,
    rec_ccp1.restriction_type             AS rec_ccp_restriction_type,
    rec_ccp1.mapi_selling_points          AS rec_ccp_mapi_selling_points,
    rec_ccp1.mapi_rank                    AS rec_ccp_mapi_rank,
    rec_ccp1.sales_commission             AS rec_ccp_sales_commission,
    rec_ccp1.sales_units                  AS rec_ccp_sales_units,
    rec_ccp1.period_commission            AS rec_ccp_period_commission,
    rec_ccp1.sold_outside_home_center     AS rec_ccp_sold_outside_home_center,
    rec_ccp1.show_on_mobile_api           AS rec_ccp_show_on_mobile_api,
    rec_ccp1.assigned_staff_group         AS rec_ccp_assigned_staff_group,
    rec_ccp1.print_qr_on_receipt          AS rec_ccp_print_qr_on_receipt,
    rec_ccp1.last_recount_date            AS rec_ccp_last_recount_date,
    rec_ccp1.single_use                   AS rec_ccp_single_use,
    rec_ccp1.flat_rate_commission         AS rec_ccp_flat_rate_commission,
    rec_ccp1.webname                      AS rec_ccp_webname,
    -------------------------------
    -------for PRORATA product for subscription
    prorata1.center                       AS prorata1_center,
    prorata1.id                           AS prorata1_id,
    prorata1.ptype                        AS prorata_ptype,
    prorata1.external_id                  AS prorata_external_id,
    prorata1.income_accountcenter         AS prorata_income_accountcenter,
    prorata1.income_accountid             AS prorata_income_accountid,
    prorata1.expense_accountcenter        AS prorata_expense_accountcenter,
    prorata1.expense_accountid            AS prorata_expense_accountid,
    prorata1.refund_accountcenter         AS prorata_refund_accountcenter,
    prorata1.refund_accountid             AS prorata_refund_accountid,
    prorata1.price                        AS prorata_price,
    prorata1.min_price                    AS prorata_min_price,
    prorata1.cost_price                   AS prorata_cost_price,
    prorata1.requiredrole                 AS prorata_requiredrole,
    prorata1.globalid                     AS prorata_globalid,
    prorata1.max_buy_qty                  AS prorata_max_buy_qty,
    prorata1.max_buy_qty_period           AS prorata_max_buy_qty_period,
    prorata1.max_buy_qty_period_type      AS prorata_max_buy_qty_period_type,
    prorata1.needs_privilege              AS prorata_needs_privilege,
    prorata1.show_in_sale                 AS prorata_show_in_sale,
    prorata1.returnable                   AS prorata_returnable,
    prorata1.show_on_web                  AS prorata_show_on_web,
    prorata1.primary_product_group_id     AS prorata_primary_product_group_id,
    prorata1.product_account_config_id    AS prorata_product_account_config_id,
    prorata1.override_price_and_text_role AS prorata_override_price_and_text_role,
    prorata1.ipc_available                AS prorata_ipc_available,
    prorata1.restriction_type             AS prorata_restriction_type,
    prorata1.mapi_selling_points          AS prorata_mapi_selling_points,
    prorata1.mapi_rank                    AS prorata_mapi_rank,
    prorata1.mapi_description             AS prorata_mapi_description,
    prorata1.sales_commission             AS prorata_sales_commission,
    prorata1.sales_units                  AS prorata_sales_units,
    prorata1.period_commission            AS prorata_period_commission,
    prorata1.sold_outside_home_center     AS prorata_sold_outside_home_center,
    prorata1.show_on_mobile_api           AS prorata_show_on_mobile_api,
    prorata1.assigned_staff_group         AS prorata_assigned_staff_group,
    prorata1.print_qr_on_receipt          AS prorata_print_qr_on_receipt,
    prorata1.last_recount_date            AS prorata_last_recount_date,
    prorata1.single_use                   AS prorata_single_use,
    prorata1.flat_rate_commission         AS prorata_flat_rate_commission,
    prorata1.webname                      AS prorata_webname,
    -------------------------------
    -------for privilege grant for subscription product
    --    sub_pgrant1.id                    AS sub_pgrant_id,
        sub_pgrant1.privilege_set         AS sub_pgrant_privilege_set,
        sub_pgrant1.punishment            AS sub_pgrant_punishment,
    --    sub_pgrant1.granter_service       AS sub_pgrant_granter_service,
        sub_pgrant1.granter_globalid      AS sub_pgrant_granter_globalid,
    --    sub_pgrant1.valid_from            AS sub_pgrant_valid_from,
    --    sub_pgrant1.valid_to              AS sub_pgrant_valid_to,
        sub_pgrant1.sponsorship_name      AS sub_pgrant_sponsorship_name,
        sub_pgrant1.sponsorship_amount    AS sub_pgrant_sponsorship_amount,
        sub_pgrant1.sponsorship_rounding  AS sub_pgrant_sponsorship_rounding,
        sub_pgrant1.usage_product         AS sub_pgrant_usage_product,
        sub_pgrant1.usage_quantity        AS sub_pgrant_usage_quantity,
        sub_pgrant1.usage_duration_value  AS sub_pgrant_usage_duration_value,
        sub_pgrant1.usage_duration_unit   AS sub_pgrant_usage_duration_unit,
        sub_pgrant1.usage_duration_round  AS sub_pgrant_usage_duration_round,
        sub_pgrant1.usage_use_at_planning AS sub_pgrant_usage_use_at_planning,
        sub_pgrant1.extension             AS sub_pgrant_extension,
    -------------------------------
    -------for privilege grant for clip card product
    --    cc_pgrant1.id                    AS cc_pgrant_id,
        cc_pgrant1.privilege_set         AS cc_pgrant_privilege_set,
        cc_pgrant1.punishment            AS cc_pgrant_punishment,
    --    cc_pgrant1.granter_service       AS cc_pgrant_granter_service,
        cc_pgrant1.granter_globalid      AS cc_pgrant_granter_globalid,
    --    cc_pgrant1.valid_from            AS cc_pgrant_valid_from,
    --    cc_pgrant1.valid_to              AS cc_pgrant_valid_to,
        cc_pgrant1.sponsorship_name      AS cc_pgrant_sponsorship_name,
        cc_pgrant1.sponsorship_amount    AS cc_pgrant_sponsorship_amount,
        cc_pgrant1.sponsorship_rounding  AS cc_pgrant_sponsorship_rounding,
        cc_pgrant1.usage_product         AS cc_pgrant_usage_product,
        cc_pgrant1.usage_quantity        AS cc_pgrant_usage_quantity,
        cc_pgrant1.usage_duration_value  AS cc_pgrant_usage_duration_value,
        cc_pgrant1.usage_duration_unit   AS cc_pgrant_usage_duration_unit,
        cc_pgrant1.usage_duration_round  AS cc_pgrant_usage_duration_round,
        cc_pgrant1.usage_use_at_planning AS cc_pgrant_usage_use_at_planning,
        cc_pgrant1.extension             AS cc_pgrant_extension,
    -------------------------------
    -------for privilege set for subscription product    
    sub_pset1.id                             AS sub_pset_id,
    sub_pset1.name                           AS sub_pset_name,
    sub_pset1.description                    AS sub_pset_description,
    sub_pset1.scope_type                     AS sub_pset_scope_type,
    sub_pset1.scope_id                       AS sub_pset_scope_id,
    sub_pset1.state                          AS sub_pset_state,
    sub_pset1.blocked_on                     AS sub_pset_blocked_on,
    sub_pset1.privilege_set_groups_id        AS sub_pset_bprivilege_set_groups_id,
    sub_pset1.time_restriction               AS sub_pset_time_restriction,
    sub_pset1.booking_window_restriction     AS sub_pset_booking_window_restriction,
    sub_pset1.frequency_restriction_count    AS sub_pset_frequency_restriction_count,
    sub_pset1.frequency_restriction_value    AS sub_pset_frequency_restriction_value,
    sub_pset1.frequency_restriction_unit     AS sub_pset_frequency_restriction_unit,
    sub_pset1.frequency_restriction_type     AS sub_pset_frequency_restriction_type,
    sub_pset1.frequency_restr_include_noshow AS sub_pset_frequency_restr_include_noshow,
    sub_pset1.reusable                       AS sub_pset_reusable,
    sub_pset1.availability_period_id         AS sub_pset_availability_period_id,
    sub_pset1.multiaccess_window_count       AS sub_pset_multiaccess_window_count,
    sub_pset1.multiaccess_window_time_value  AS sub_pset_multiaccess_window_time_value,
    sub_pset1.multiaccess_window_time_unit   AS sub_pset_multiaccess_window_time_unit,
    sub_pset1.multiaccess_window_type        AS sub_pset_multiaccess_window_type,
    -------------------------------
    -------for privilege set for clipcard product        
    cc_pset1.id                              AS cc_pset_id,
    cc_pset1.name                            AS cc_pset_name,
    cc_pset1.description                     AS cc_pset_description,
    cc_pset1.scope_type                      AS cc_pset_scope_type,
    cc_pset1.scope_id                        AS cc_pset_scope_id,
    cc_pset1.state                           AS cc_pset_state,
    cc_pset1.blocked_on                      AS cc_pset_blocked_on,
    cc_pset1.privilege_set_groups_id         AS cc_pset_bprivilege_set_groups_id,
    cc_pset1.time_restriction                AS cc_pset_time_restriction,
    cc_pset1.booking_window_restriction      AS cc_pset_booking_window_restriction,
    cc_pset1.frequency_restriction_count     AS cc_pset_frequency_restriction_count,
    cc_pset1.frequency_restriction_value     AS cc_pset_frequency_restriction_value,
    cc_pset1.frequency_restriction_unit      AS cc_pset_frequency_restriction_unit,
    cc_pset1.frequency_restriction_type      AS cc_pset_frequency_restriction_type,
    cc_pset1.frequency_restr_include_noshow  AS cc_pset_frequency_restr_include_noshow,
    cc_pset1.reusable                        AS cc_pset_reusable,
    cc_pset1.availability_period_id          AS cc_pset_availability_period_id,
    cc_pset1.multiaccess_window_count        AS cc_pset_multiaccess_window_count,
    cc_pset1.multiaccess_window_time_value   AS cc_pset_multiaccess_window_time_value,
    cc_pset1.multiaccess_window_time_unit    AS cc_pset_multiaccess_window_time_unit,
    cc_pset1.multiaccess_window_type         AS cc_pset_multiaccess_window_type
FROM
    products p1
JOIN
    product_group pg1
ON
    p1.primary_product_group_id = pg1.id
JOIN
    subscriptiontypes st1
ON
    p1.center = st1.center
AND p1.id = st1.id
LEFT JOIN
    products rec_ccp1
ON
    st1.rec_clipcard_product_center = rec_ccp1.center
AND st1.rec_clipcard_product_id = rec_ccp1.id
LEFT JOIN
    products prorata1
ON
    st1.prorataproduct_center = prorata1.center
AND st1.prorataproduct_id = prorata1.id
LEFT JOIN
    masterproductregister sub_mpr1
ON
    p1.globalid = sub_mpr1.globalid
LEFT JOIN
    privilege_grants sub_pgrant1
ON
    sub_pgrant1.granter_id = sub_mpr1.id
LEFT JOIN
    privilege_sets sub_pset1
ON
    sub_pgrant1.privilege_set = sub_pset1.id
LEFT JOIN
    masterproductregister cc_mpr1
ON
    rec_ccp1.globalid = cc_mpr1.globalid
LEFT JOIN
    privilege_grants cc_pgrant1
ON
    cc_pgrant1.granter_id = cc_mpr1.id
LEFT JOIN
    privilege_sets cc_pset1
ON
    cc_pgrant1.privilege_set = cc_pset1.id
    ----------------------------------
    ----------------------------------
    ----SET THE PRODUCT CENTER AND ID FOR THE BASELINE PRODUCT AND THE AUDIT PRODUCT(S) RESULT-----
    -- 00000000000000000000
WHERE
    p1.blocked = 'false'
AND pg1.state = 'ACTIVE'
AND p1.ptype = 10 -- Subscription
AND (
        p1.center||'pr'||p1.id) IN (:ProductKey) --<<<<<<<<<< from product audit column 3 --