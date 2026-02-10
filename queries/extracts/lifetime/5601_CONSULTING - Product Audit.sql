-- The extract is extracted from Exerp on 2026-02-08
-- Compares product configuration for one selected product to all products with the entered global ID. It's possible to use % as a wildcard at the end of the Global ID, for example MCA_SEMI_PVT_60_MIN_SUB_LV% or MCA%
WITH
    baseline AS
    (
        SELECT
            -------------------------------
            -------for subscription product
            p1.ptype AS p_ptype,
            CASE
                WHEN p1.external_id IS NOT NULL
                THEN 1
                ELSE 0
            END                      AS p_external_id,
            p1.income_accountcenter  AS p_income_accountcenter,
            p1.income_accountid      AS p_income_accountid,
            p1.expense_accountcenter AS p_expense_accountcenter,
            p1.expense_accountid     AS p_expense_accountid,
            p1.refund_accountcenter  AS p_refund_accountcenter,
            p1.refund_accountid      AS p_refund_accountid,
            CASE
                WHEN p1.price > 0
                THEN 1
                ELSE 0
            END                             AS p_price,
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
            pg1.id                        AS pg_id,
            pg1.top_node_id               AS pg_top_node_id,
            pg1.scope_type                AS pg_scope_type,
            pg1.scope_id                  AS pg_scope_id,
            pg1.state                     AS pg_state,
            pg1.parent_product_group_id   AS pg_parent_product_group_id,
            pg1.show_in_shop              AS pg_show_in_shop,
            pg1.product_account_config_id AS pg_product_account_config_id,
            pg1.colour_group_id           AS pg_colour_group_id,
            CASE
                WHEN pg1.ranking > 0
                THEN 1
                ELSE 0
            END                               AS pg_ranking,
            pg1.in_subscription_sales         AS pg_in_subscription_sales,
            pg1.hide_in_report_parameters     AS pg_hide_in_report_parameters,
            pg1.exclude_from_member_count     AS pg_exclude_from_member_count,
            pg1.exclude_from_product_cleaning AS pg_exclude_from_product_cleaning ,
            pg1.client_profile_id             AS pg_client_profile_id,
            CASE
                WHEN pg1.external_id IS NOT NULL
                THEN 1
                ELSE 0
            END                            AS pg_external_id,
            pg1.single_product_in_basket   AS pg_single_product_in_basket,
            pg1.dimension_product_group_id AS pg_dimension_product_group_id,
            -------------------------------
            -------for subscription type table
            st1.st_type                   AS st_st_type,
            st1.use_individual_price      AS st_use_individual_price,
            st1.floatingperiod            AS st_floatingperiod,
            st1.prorataperiodcount        AS st_prorataperiodcount,
            st1.extend_binding_by_prorata AS st_extend_binding_by_prorata,
            st1.initialperiodcount        AS st_initialperiodcount,
            st1.extend_binding_by_initial AS st_extend_binding_by_initial,
            st1.bindingperiodcount        AS st_bindingperiodcount,
            st1.periodunit                AS st_periodunit,
            st1.periodcount               AS st_periodcount,
            st1.age_restriction_type      AS st_age_restriction_type,
            st1.age_restriction_value     AS st_age_restriction_value,
            st1.sex_restriction           AS st_sex_restriction,
            CASE
                WHEN st1.freezeperiodproduct_center > 0
                THEN 1
                ELSE 0
            END AS st_freezeperiodproduct_center,
            CASE
                WHEN st1.freezestartupproduct_center > 0
                THEN 1
                ELSE 0
            END AS st_freezestartupproduct_center,
            CASE
                WHEN st1.transferproduct_center > 0
                THEN 1
                ELSE 0
            END AS st_transferproduct_center,
            CASE
                WHEN st1.add_on_to_center > 0
                THEN 1
                ELSE 0
            END              AS st_add_on_to_center,
            st1.renew_window AS st_renew_window,
            CASE
                WHEN st1.rank > 0
                THEN 1
                ELSE 0
            END                       AS st_rank,
            st1.is_addon_subscription AS st_is_addon_subscription,
            CASE
                WHEN st1.prorataproduct_center > 0
                THEN 1
                ELSE 0
            END AS st_prorataproduct_center,
            CASE
                WHEN st1.adminfeeproduct_center > 0
                THEN 1
                ELSE 0
            END                             AS st_adminfeeproduct_center,
            st1.clearing_house_restriction    AS st_clearing_house_restriction,
            st1.is_price_update_excluded      AS st_is_price_update_excluded,
            st1.start_date_limit_count        AS st_start_date_limit_count,
            st1.start_date_limit_unit         AS st_start_date_limit_unit,
            st1.start_date_restriction        AS st_start_date_restriction,
            st1.auto_stop_on_binding_end_date AS st_auto_stop_on_binding_end_date,
            st1.roundup_end_unit              AS st_roundup_end_unit,
            CASE
                WHEN st1.buyoutfeeproduct_center > 0
                THEN 1
                ELSE 0
            END AS st_buyoutfeeproduct_center,
            CASE
                WHEN st1.rec_clipcard_product_center > 0
                THEN 1
                ELSE 0
            END                           AS st_rec_clipcard_product_center,
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
            CASE
                WHEN st1.rec_clipcard_pack_size IS NOT NULL
                THEN 1
                ELSE 0
            END AS st_rec_clipcard_pack_size,
            -------------------------------
            -------for clipcard product for recurring subscription
            rec_ccp1.ptype AS rec_ccp_ptype,
            CASE
                WHEN rec_ccp1.external_id IS NOT NULL
                THEN 1
                ELSE 0
            END                            AS rec_ccp_external_id,
            rec_ccp1.income_accountcenter  AS rec_ccp_income_accountcenter,
            rec_ccp1.income_accountid      AS rec_ccp_income_accountid,
            rec_ccp1.expense_accountcenter AS rec_ccp_expense_accountcenter,
            rec_ccp1.expense_accountid     AS rec_ccp_expense_accountid,
            rec_ccp1.refund_accountcenter  AS rec_ccp_refund_accountcenter,
            rec_ccp1.refund_accountid      AS rec_ccp_refund_accountid,
            CASE
                WHEN rec_ccp1.price > 0
                THEN 1
                ELSE 0
            END                   AS rec_ccp_price,
            rec_ccp1.min_price    AS rec_ccp_min_price,
            rec_ccp1.cost_price   AS rec_ccp_cost_price,
            rec_ccp1.requiredrole AS rec_ccp_requiredrole,
            CASE
                WHEN rec_ccp1.globalid IS NOT NULL
                THEN 1
                ELSE 0
            END                                  AS rec_ccp_globalid,
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
            prorata1.ptype AS prorata_ptype,
            CASE
                WHEN prorata1.external_id IS NOT NULL
                THEN 1
                ELSE 0
            END                            AS prorata_external_id,
            prorata1.income_accountcenter  AS prorata_income_accountcenter,
            prorata1.income_accountid      AS prorata_income_accountid,
            prorata1.expense_accountcenter AS prorata_expense_accountcenter,
            prorata1.expense_accountid     AS prorata_expense_accountid,
            prorata1.refund_accountcenter  AS prorata_refund_accountcenter,
            prorata1.refund_accountid      AS prorata_refund_accountid,
            CASE
                WHEN prorata1.price > 0
                THEN 1
                ELSE 0
            END                   AS prorata_price,
            prorata1.min_price    AS prorata_min_price,
            prorata1.cost_price   AS prorata_cost_price,
            prorata1.requiredrole AS prorata_requiredrole,
            CASE
                WHEN prorata1.globalid IS NOT NULL
                THEN 1
                ELSE 0
            END                                  AS prorata_globalid,
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
            -------for privilege grant for subscription product
            --    sub_pgrant1.id                    AS sub_pgrant_id,
            sub_pgrant1.privilege_set AS sub_pgrant_privilege_set,
            sub_pgrant1.punishment    AS sub_pgrant_punishment,
            --    sub_pgrant1.granter_service       AS sub_pgrant_granter_service,
            sub_pgrant1.granter_globalid AS sub_pgrant_granter_globalid,
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
            cc_pgrant1.privilege_set AS cc_pgrant_privilege_set,
            cc_pgrant1.punishment    AS cc_pgrant_punishment,
            --    cc_pgrant1.granter_service       AS cc_pgrant_granter_service,
            cc_pgrant1.granter_globalid AS cc_pgrant_granter_globalid,
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
            cc_pset1.id                             AS cc_pset_id,
            cc_pset1.name                           AS cc_pset_name,
            cc_pset1.description                    AS cc_pset_description,
            cc_pset1.scope_type                     AS cc_pset_scope_type,
            cc_pset1.scope_id                       AS cc_pset_scope_id,
            cc_pset1.state                          AS cc_pset_state,
            cc_pset1.blocked_on                     AS cc_pset_blocked_on,
            cc_pset1.privilege_set_groups_id        AS cc_pset_bprivilege_set_groups_id,
            cc_pset1.time_restriction               AS cc_pset_time_restriction,
            cc_pset1.booking_window_restriction     AS cc_pset_booking_window_restriction,
            cc_pset1.frequency_restriction_count    AS cc_pset_frequency_restriction_count,
            cc_pset1.frequency_restriction_value    AS cc_pset_frequency_restriction_value,
            cc_pset1.frequency_restriction_unit     AS cc_pset_frequency_restriction_unit,
            cc_pset1.frequency_restriction_type     AS cc_pset_frequency_restriction_type,
            cc_pset1.frequency_restr_include_noshow AS cc_pset_frequency_restr_include_noshow,
            cc_pset1.reusable                       AS cc_pset_reusable,
            cc_pset1.availability_period_id         AS cc_pset_availability_period_id,
            cc_pset1.multiaccess_window_count       AS cc_pset_multiaccess_window_count,
            cc_pset1.multiaccess_window_time_value  AS cc_pset_multiaccess_window_time_value,
            cc_pset1.multiaccess_window_time_unit   AS cc_pset_multiaccess_window_time_unit,
            cc_pset1.multiaccess_window_type        AS cc_pset_multiaccess_window_type
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
            rec_ccp1.globalid = sub_mpr1.globalid
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
            ----SET THE BASELINE product center and product ID-----00000000000000000000
        WHERE
            p1.center = :BaselineProductCenter --<<<<<<<<
        AND p1.globalid = :BaselineProductGlobalID --<<<<<<<<<<
        AND p1.ptype = 10 -- Subscription
        AND p1.blocked = 'false'
        AND pg1.state = 'ACTIVE'
    )
SELECT
    -------------------------------
    ------ SUBSCRIPTION PRODUCT
    -------for subscription product
    pg.name                        AS pg2_name,
    pg.id                          AS pg2_id,
    p.center||'pr'||p.id           AS p2_product_id,
    p.center                       AS p2_center,
    p.id                           AS p2_id,
    p.name                         AS p2_name,
    p.ptype                        AS p2_ptype,
    p.external_id                  AS p2_external_id,
    p.income_accountcenter         AS p2_income_accountcenter,
    p.income_accountid             AS p2_income_accountid,
    p.expense_accountcenter        AS p2_expense_accountcenter,
    p.expense_accountid            AS p2_expense_accountid,
    p.refund_accountcenter         AS p2_refund_accountcenter,
    p.refund_accountid             AS p2_refund_accountid,
    p.price                        AS p2_price,
    p.min_price                    AS p2_min_price,
    p.cost_price                   AS p2_cost_price,
    p.requiredrole                 AS p2_requiredrole,
    p.globalid                     AS p2_globalid,
    p.max_buy_qty                  AS p2_max_buy_qty,
    p.max_buy_qty_period           AS p2_max_buy_qty_period,
    p.max_buy_qty_period_type      AS p2_max_buy_qty_period_type,
    p.needs_privilege              AS p2_needs_privilege,
    p.show_in_sale                 AS p2_show_in_sale,
    p.returnable                   AS p2_returnable,
    p.show_on_web                  AS p2_show_on_web,
    p.primary_product_group_id     AS p2_primary_product_group_id,
    p.product_account_config_id    AS p2_product_account_config_id,
    p.override_price_and_text_role AS p2_override_price_and_text_role,
    p.ipc_available                AS p2_ipc_available,
    p.restriction_type             AS p2_restriction_type,
    p.mapi_selling_points          AS p2_mapi_selling_points,
    p.mapi_rank                    AS p2_mapi_rank,
    --          --mapi_description not included as it's written text description
    p.sales_commission         AS p2_sales_commission,
    p.sales_units              AS p2_sales_units,
    p.period_commission        AS p2_period_commission,
    p.sold_outside_home_center AS p2_sold_outside_home_center,
    p.show_on_mobile_api       AS p2_show_on_mobile_api,
    p.assigned_staff_group     AS p2_assigned_staff_group,
    p.print_qr_on_receipt      AS p2_print_qr_on_receipt,
    p.last_recount_date        AS p2_last_recount_date,
    p.single_use               AS p2_single_use,
    p.flat_rate_commission     AS p2_flat_rate_commission,
    p.webname                  AS p2_webname,
    -------------------------------
    -------for product_group table
    pg.id                            AS pg2_id,
    pg.top_node_id                   AS pg2_top_node_id,
    pg.scope_type                    AS pg2_scope_type,
    pg.scope_id                      AS pg2_scope_id,
    pg.state                         AS pg2_state,
    pg.parent_product_group_id       AS pg2_parent_product_group_id,
    pg.show_in_shop                  AS pg2_show_in_shop,
    pg.product_account_config_id     AS pg2_product_account_config_id,
    pg.colour_group_id               AS pg2_colour_group_id,
    pg.ranking                       AS pg2_ranking,
    pg.in_subscription_sales         AS pg2_in_subscription_sales,
    pg.hide_in_report_parameters     AS pg2_hide_in_report_parameters,
    pg.exclude_from_member_count     AS pg2_exclude_from_member_count,
    pg.exclude_from_product_cleaning AS pg2_exclude_from_product_cleaning ,
    pg.client_profile_id             AS pg2_client_profile_id,
    pg.external_id                   AS pg2_external_id,
    pg.single_product_in_basket      AS pg2_single_product_in_basket,
    pg.dimension_product_group_id    AS pg2_dimension_product_group_id,
    -------------------------------
    -------for subscription type table
    st.st_type                        AS st2_st_type,
    st.use_individual_price           AS st2_use_individual_price,
    st.floatingperiod                 AS st2_floatingperiod,
    st.prorataperiodcount             AS st2_prorataperiodcount,
    st.extend_binding_by_prorata      AS st2_extend_binding_by_prorata,
    st.initialperiodcount             AS st2_initialperiodcount,
    st.extend_binding_by_initial      AS st2_extend_binding_by_initial,
    st.bindingperiodcount             AS st2_bindingperiodcount,
    st.periodunit                     AS st2_periodunit,
    st.periodcount                    AS st2_periodcount,
    st.age_restriction_type           AS st2_age_restriction_type,
    st.age_restriction_value          AS st2_age_restriction_value,
    st.sex_restriction                AS st2_sex_restriction,
    st.freezeperiodproduct_center     AS st2_freezeperiodproduct_center,
    st.freezestartupproduct_center    AS st2_freezestartupproduct_center,
    st.transferproduct_center         AS st2_transferproduct_center,
    st.add_on_to_center               AS st2_add_on_to_center,
    st.renew_window                   AS st2_renew_window,
    st.rank                           AS st2_rank,
    st.is_addon_subscription          AS st2_is_addon_subscription,
    st.prorataproduct_center          AS st2_prorataproduct_center,
    st.adminfeeproduct_center         AS st2_adminfeeproduct_center,
    st.clearing_house_restriction     AS st2_clearing_house_restriction,
    st.is_price_update_excluded       AS st2_is_price_update_excluded,
    st.start_date_limit_count         AS st2_start_date_limit_count,
    st.start_date_limit_unit          AS st2_start_date_limit_unit,
    st.start_date_restriction         AS st2_start_date_restriction,
    st.auto_stop_on_binding_end_date  AS st2_auto_stop_on_binding_end_date,
    st.roundup_end_unit               AS st2_roundup_end_unit,
    st.buyoutfeeproduct_center        AS st2_buyoutfeeproduct_center,
    st.rec_clipcard_product_center    AS st2_rec_clipcard_product_center,
    st.autorenew_binding_count        AS st2_autorenew_binding_count,
    st.autorenew_binding_unit         AS st2_autorenew_binding_unit,
    st.autorenew_binding_notice_count AS st2_autorenew_binding_notice_count,
    st.autorenew_binding_notice_unit  AS st2_autorenew_binding_notice_unit,
    st.sale_startup_clipcard          AS st2_sale_startup_clipcard,
    st.unrestricted_freeze_allowed    AS st2_unrestricted_freeze_allowed,
    st.buyout_fee_percentage          AS st2_buyout_fee_percentage,
    st.change_requiredrole            AS st2_change_requiredrole,
    st.reactivation_allowed           AS st2_reactivation_allowed,
    st.can_be_reassigned              AS st2_can_be_reassigned,
    st.rec_clipcard_pack_size         AS st2_rec_clipcard_pack_size,
    -------------------------------
    -------for clipcard product for recurring subscription
    rec_ccp.ptype                        AS rec_ccp2_ptype,
    rec_ccp.external_id                  AS rec_ccp2_external_id,
    rec_ccp.income_accountcenter         AS rec_ccp2_income_accountcenter,
    rec_ccp.income_accountid             AS rec_ccp2_income_accountid,
    rec_ccp.expense_accountcenter        AS rec_ccp2_expense_accountcenter,
    rec_ccp.expense_accountid            AS rec_ccp2_expense_accountid,
    rec_ccp.refund_accountcenter         AS rec_ccp2_refund_accountcenter,
    rec_ccp.refund_accountid             AS rec_ccp2_refund_accountid,
    rec_ccp.price                        AS rec_ccp2_price,
    rec_ccp.min_price                    AS rec_ccp2_min_price,
    rec_ccp.cost_price                   AS rec_ccp2_cost_price,
    rec_ccp.requiredrole                 AS rec_ccp2_requiredrole,
    rec_ccp.globalid                     AS rec_ccp2_globalid,
    rec_ccp.max_buy_qty                  AS rec_ccp2_max_buy_qty,
    rec_ccp.max_buy_qty_period           AS rec_ccp2_max_buy_qty_period,
    rec_ccp.max_buy_qty_period_type      AS rec_ccp2_max_buy_qty_period_type,
    rec_ccp.needs_privilege              AS rec_ccp2_needs_privilege,
    rec_ccp.show_in_sale                 AS rec_ccp2_show_in_sale,
    rec_ccp.returnable                   AS rec_ccp2_returnable,
    rec_ccp.show_on_web                  AS rec_ccp2_show_on_web,
    rec_ccp.primary_product_group_id     AS rec_ccp2_primary_product_group_id,
    rec_ccp.product_account_config_id    AS rec_ccp2_product_account_config_id,
    rec_ccp.override_price_and_text_role AS rec_ccp2_override_price_and_text_role,
    rec_ccp.ipc_available                AS rec_ccp2_ipc_available,
    rec_ccp.restriction_type             AS rec_ccp2_restriction_type,
    rec_ccp.mapi_selling_points          AS rec_ccp2_mapi_selling_points,
    rec_ccp.mapi_rank                    AS rec_ccp2_mapi_rank,
    rec_ccp.sales_commission             AS rec_ccp2_sales_commission,
    rec_ccp.sales_units                  AS rec_ccp2_sales_units,
    rec_ccp.period_commission            AS rec_ccp2_period_commission,
    rec_ccp.sold_outside_home_center     AS rec_ccp2_sold_outside_home_center,
    rec_ccp.show_on_mobile_api           AS rec_ccp2_show_on_mobile_api,
    rec_ccp.assigned_staff_group         AS rec_ccp2_assigned_staff_group,
    rec_ccp.print_qr_on_receipt          AS rec_ccp2_print_qr_on_receipt,
    rec_ccp.last_recount_date            AS rec_ccp2_last_recount_date,
    rec_ccp.single_use                   AS rec_ccp2_single_use,
    rec_ccp.flat_rate_commission         AS rec_ccp2_flat_rate_commission,
    rec_ccp.webname                      AS rec_ccp2_webname,
    -------------------------------
    -------for PRORATA product for subscription
    prorata.ptype                        AS prorata2_ptype,
    prorata.external_id                  AS prorata2_external_id,
    prorata.income_accountcenter         AS prorata2_income_accountcenter,
    prorata.income_accountid             AS prorata2_income_accountid,
    prorata.expense_accountcenter        AS prorata2_expense_accountcenter,
    prorata.expense_accountid            AS prorata2_expense_accountid,
    prorata.refund_accountcenter         AS prorata2_refund_accountcenter,
    prorata.refund_accountid             AS prorata2_refund_accountid,
    prorata.price                        AS prorata2_price,
    prorata.min_price                    AS prorata2_min_price,
    prorata.cost_price                   AS prorata2_cost_price,
    prorata.requiredrole                 AS prorata2_requiredrole,
    prorata.globalid                     AS prorata2_globalid,
    prorata.max_buy_qty                  AS prorata2_max_buy_qty,
    prorata.max_buy_qty_period           AS prorata2_max_buy_qty_period,
    prorata.max_buy_qty_period_type      AS prorata2_max_buy_qty_period_type,
    prorata.needs_privilege              AS prorata2_needs_privilege,
    prorata.show_in_sale                 AS prorata2_show_in_sale,
    prorata.returnable                   AS prorata2_returnable,
    prorata.show_on_web                  AS prorata2_show_on_web,
    prorata.primary_product_group_id     AS prorata2_primary_product_group_id,
    prorata.product_account_config_id    AS prorata2_product_account_config_id,
    prorata.override_price_and_text_role AS prorata2_override_price_and_text_role,
    prorata.ipc_available                AS prorata2_ipc_available,
    prorata.restriction_type             AS prorata2_restriction_type,
    prorata.mapi_selling_points          AS prorata2_mapi_selling_points,
    prorata.mapi_rank                    AS prorata2_mapi_rank,
    prorata.mapi_description             AS prorata2_mapi_description,
    prorata.sales_commission             AS prorata2_sales_commission,
    prorata.sales_units                  AS prorata2_sales_units,
    prorata.period_commission            AS prorata2_period_commission,
    prorata.sold_outside_home_center     AS prorata2_sold_outside_home_center,
    prorata.show_on_mobile_api           AS prorata2_show_on_mobile_api,
    prorata.assigned_staff_group         AS prorata2_assigned_staff_group,
    prorata.print_qr_on_receipt          AS prorata2_print_qr_on_receipt,
    prorata.last_recount_date            AS prorata2_last_recount_date,
    prorata.single_use                   AS prorata2_single_use,
    prorata.flat_rate_commission         AS prorata2_flat_rate_commission,
    prorata.webname                      AS prorata2_webname,
    -------------------------------
    -------for privilege grant for clip card product
    sub_pgrant.privilege_set         AS sub_pgrant2_privilege_set,
    sub_pgrant.punishment            AS sub_pgrant2_punishment,
    sub_pgrant.granter_service       AS sub_pgrant2_granter_service,
    sub_pgrant.granter_globalid      AS sub_pgrant2_granter_globalid,
    sub_pgrant.valid_from            AS sub_pgrant2_valid_from,
    sub_pgrant.valid_to              AS sub_pgrant2_valid_to,
    sub_pgrant.sponsorship_name      AS sub_pgrant2_sponsorship_name,
    sub_pgrant.sponsorship_amount    AS sub_pgrant2_sponsorship_amount,
    sub_pgrant.sponsorship_rounding  AS sub_pgrant2_sponsorship_rounding,
    sub_pgrant.usage_product         AS sub_pgrant2_usage_product,
    sub_pgrant.usage_quantity        AS sub_pgrant2_usage_quantity,
    sub_pgrant.usage_duration_value  AS sub_pgrant2_usage_duration_value,
    sub_pgrant.usage_duration_unit   AS sub_pgrant2_usage_duration_unit,
    sub_pgrant.usage_duration_round  AS sub_pgrant2_usage_duration_round,
    sub_pgrant.usage_use_at_planning AS sub_pgrant2_usage_use_at_planning,
    sub_pgrant.extension             AS sub_pgrant2_extension,
    -------------------------------
    -------for privilege grant for clip card product
    cc_pgrant.privilege_set AS cc_pgrant2_privilege_set,
    cc_pgrant.punishment    AS cc_pgrant2_punishment,
    --    cc_pgrant.granter_service       AS cc_pgrant2_granter_service,
    cc_pgrant.granter_globalid AS cc_pgrant2_granter_globalid,
    --    cc_pgrant.valid_from            AS cc_pgrant2_valid_from,
    --    cc_pgrant.valid_to              AS cc_pgrant2_valid_to,
    cc_pgrant.sponsorship_name      AS cc_pgrant2_sponsorship_name,
    cc_pgrant.sponsorship_amount    AS cc_pgrant2_sponsorship_amount,
    cc_pgrant.sponsorship_rounding  AS cc_pgrant2_sponsorship_rounding,
    cc_pgrant.usage_product         AS cc_pgrant2_usage_product,
    cc_pgrant.usage_quantity        AS cc_pgrant2_usage_quantity,
    cc_pgrant.usage_duration_value  AS cc_pgrant2_usage_duration_value,
    cc_pgrant.usage_duration_unit   AS cc_pgrant2_usage_duration_unit,
    cc_pgrant.usage_duration_round  AS cc_pgrant2_usage_duration_round,
    cc_pgrant.usage_use_at_planning AS cc_pgrant2_usage_use_at_planning,
    cc_pgrant.extension             AS cc_pgrant2_extension,
    -------------------------------
    -------for privilege set for subscription product
    sub_pset.id                             AS sub_pset2_id,
    sub_pset.name                           AS sub_pset2_name,
    sub_pset.description                    AS sub_pset2_description,
    sub_pset.scope_type                     AS sub_pset2_scope_type,
    sub_pset.scope_id                       AS sub_pset2_scope_id,
    sub_pset.state                          AS sub_pset2_state,
    sub_pset.blocked_on                     AS sub_pset2_blocked_on,
    sub_pset.privilege_set_groups_id        AS sub_pset2_bprivilege_set_groups_id,
    sub_pset.time_restriction               AS sub_pset2_time_restriction,
    sub_pset.booking_window_restriction     AS sub_pset2_booking_window_restriction,
    sub_pset.frequency_restriction_count    AS sub_pset2_frequency_restriction_count,
    sub_pset.frequency_restriction_value    AS sub_pset2_frequency_restriction_value,
    sub_pset.frequency_restriction_unit     AS sub_pset2_frequency_restriction_unit,
    sub_pset.frequency_restriction_type     AS sub_pset2_frequency_restriction_type,
    sub_pset.frequency_restr_include_noshow AS sub_pset2_frequency_restr_include_noshow,
    sub_pset.reusable                       AS sub_pset2_reusable,
    sub_pset.availability_period_id         AS sub_pset2_availability_period_id,
    sub_pset.multiaccess_window_count       AS sub_pset2_multiaccess_window_count,
    sub_pset.multiaccess_window_time_value  AS sub_pset2_multiaccess_window_time_value,
    sub_pset.multiaccess_window_time_unit   AS sub_pset2_multiaccess_window_time_unit,
    sub_pset.multiaccess_window_type        AS sub_pset2_multiaccess_window_type,
    -------------------------------
    -------for privilege set for clipcard product
    cc_pset.id                             AS cc_pset2_id,
    cc_pset.name                           AS cc_pset2_name,
    cc_pset.description                    AS cc_pset2_description,
    cc_pset.scope_type                     AS cc_pset2_scope_type,
    cc_pset.scope_id                       AS cc_pset2_scope_id,
    cc_pset.state                          AS cc_pset2_state,
    cc_pset.blocked_on                     AS cc_pset2_blocked_on,
    cc_pset.privilege_set_groups_id        AS cc_pset2_bprivilege_set_groups_id,
    cc_pset.time_restriction               AS cc_pset2_time_restriction,
    cc_pset.booking_window_restriction     AS cc_pset2_booking_window_restriction,
    cc_pset.frequency_restriction_count    AS cc_pset2_frequency_restriction_count,
    cc_pset.frequency_restriction_value    AS cc_pset2_frequency_restriction_value,
    cc_pset.frequency_restriction_unit     AS cc_pset2_frequency_restriction_unit,
    cc_pset.frequency_restriction_type     AS cc_pset2_frequency_restriction_type,
    cc_pset.frequency_restr_include_noshow AS cc_pset2_frequency_restr_include_noshow,
    cc_pset.reusable                       AS cc_pset2_reusable,
    cc_pset.availability_period_id         AS cc_pset2_availability_period_id,
    cc_pset.multiaccess_window_count       AS cc_pset2_multiaccess_window_count,
    cc_pset.multiaccess_window_time_value  AS cc_pset2_multiaccess_window_time_value,
    cc_pset.multiaccess_window_time_unit   AS cc_pset2_multiaccess_window_time_unit,
    cc_pset.multiaccess_window_type        AS cc_pset2_multiaccess_window_type
FROM
    products p
JOIN
    product_group pg
ON
    p.primary_product_group_id = pg.id
JOIN
    subscriptiontypes st
ON
    p.center = st.center
AND p.id = st.id
LEFT JOIN
    products rec_ccp
ON
    st.rec_clipcard_product_center = rec_ccp.center
AND st.rec_clipcard_product_id = rec_ccp.id
LEFT JOIN
    products prorata
ON
    st.prorataproduct_center = prorata.center
AND st.prorataproduct_id = prorata.id
LEFT JOIN
    masterproductregister sub_mpr
ON
    rec_ccp.globalid = sub_mpr.globalid
LEFT JOIN
    privilege_grants sub_pgrant
ON
    sub_pgrant.granter_id = sub_mpr.id
LEFT JOIN
    privilege_sets sub_pset
ON
    sub_pgrant.privilege_set = sub_pset.id
LEFT JOIN
    masterproductregister cc_mpr
ON
    rec_ccp.globalid = cc_mpr.globalid
LEFT JOIN
    privilege_grants cc_pgrant
ON
    cc_pgrant.granter_id = cc_mpr.id
LEFT JOIN
    privilege_sets cc_pset
ON
    cc_pgrant.privilege_set = cc_pset.id
    ----------------------------------------
    ----------------------------------------
    ----SET THE COMPARISON GLOBAL ID(S) -----00000000000000000000
WHERE
    p.blocked = 'false'
AND p.ptype = 10 -- Subscription
AND pg.state = 'ACTIVE'
    --AND p.center IN COLON (NOT WORKING)OverrideProductCenters --No known option right now to select multiple
    -- centers
AND p.globalid LIKE :GlobalID --<<<<<<<<<<
AND (
        p.ptype,
        CASE
            WHEN p.external_id IS NOT NULL
            THEN 1
            ELSE 0
        END, p.income_accountcenter, p.income_accountid , p.expense_accountcenter,
        p.expense_accountid, p.refund_accountcenter, p.refund_accountid,
        CASE
            WHEN p.price > 0
            THEN 1
            ELSE 0
        END, p.min_price, p.cost_price, p.requiredrole, p.globalid, p.max_buy_qty,
        p.max_buy_qty_period, p.max_buy_qty_period_type, p.needs_privilege, p.show_in_sale,
        p.returnable, p.show_on_web, p.primary_product_group_id, p.product_account_config_id,
        p.override_price_and_text_role, p.ipc_available, p.restriction_type, p.mapi_selling_points,
        p.mapi_rank, p.sales_commission, p.sales_units, p.period_commission,
        p.sold_outside_home_center, p.show_on_mobile_api, p.assigned_staff_group,
        p.print_qr_on_receipt, p.last_recount_date, p.single_use, p.flat_rate_commission, p.webname
        , pg.id, pg.top_node_id, pg.scope_type, pg.scope_id, pg.state, pg.parent_product_group_id,
        pg.show_in_shop, pg.product_account_config_id, pg.colour_group_id,
        CASE
            WHEN pg.ranking > 0
            THEN 1
            ELSE 0
        END, pg.in_subscription_sales, pg.hide_in_report_parameters, pg.exclude_from_member_count,
        pg.exclude_from_product_cleaning, pg.client_profile_id,
        CASE
            WHEN pg.external_id IS NOT NULL
            THEN 1
            ELSE 0
        END, pg.single_product_in_basket, pg.dimension_product_group_id, st.st_type,
        st.use_individual_price, st.floatingperiod, st.prorataperiodcount,
        st.extend_binding_by_prorata, st.initialperiodcount, st.extend_binding_by_initial,
        st.bindingperiodcount, st.periodunit, st.periodcount, st.age_restriction_type,
        st.age_restriction_value, st.sex_restriction,
        CASE
            WHEN st.freezeperiodproduct_center > 0
            THEN 1
            ELSE 0
        END,
        CASE
            WHEN st.freezestartupproduct_center > 0
            THEN 1
            ELSE 0
        END,
        CASE
            WHEN st.transferproduct_center > 0
            THEN 1
            ELSE 0
        END,
        CASE
            WHEN st.add_on_to_center > 0
            THEN 1
            ELSE 0
        END, st.renew_window,
        CASE
            WHEN st.rank > 0
            THEN 1
            ELSE 0
        END, st.is_addon_subscription,
        CASE
            WHEN st.prorataproduct_center > 0
            THEN 1
            ELSE 0
        END,
        CASE
            WHEN st.adminfeeproduct_center > 0
            THEN 1
            ELSE 0
        END, st.clearing_house_restriction, st.is_price_update_excluded, st.start_date_limit_count,
        st.start_date_limit_unit, st.start_date_restriction, st.auto_stop_on_binding_end_date,
        st.roundup_end_unit,
        CASE
            WHEN st.buyoutfeeproduct_center > 0
            THEN 1
            ELSE 0
        END,
        CASE
            WHEN st.rec_clipcard_product_center > 0
            THEN 1
            ELSE 0
        END, st.autorenew_binding_count, st.autorenew_binding_unit,
        st.autorenew_binding_notice_count, st.autorenew_binding_notice_unit,
        st.sale_startup_clipcard, st.unrestricted_freeze_allowed, st.buyout_fee_percentage,
        st.change_requiredrole, st.reactivation_allowed, st.can_be_reassigned,
        CASE
            WHEN st.rec_clipcard_pack_size IS NOT NULL
            THEN 1
            ELSE 0
        END, rec_ccp.ptype,
        CASE
            WHEN rec_ccp.external_id IS NOT NULL
            THEN 1
            ELSE 0
        END, rec_ccp.income_accountcenter , rec_ccp.income_accountid, rec_ccp.expense_accountcenter
        , rec_ccp.expense_accountid, rec_ccp.refund_accountcenter, rec_ccp.refund_accountid,
        CASE
            WHEN rec_ccp.price > 0
            THEN 1
            ELSE 0
        END, rec_ccp.min_price, rec_ccp.cost_price, rec_ccp.requiredrole,
        CASE
            WHEN rec_ccp.globalid IS NOT NULL
            THEN 1
            ELSE 0
        END, rec_ccp.max_buy_qty, rec_ccp.max_buy_qty_period, rec_ccp.max_buy_qty_period_type,
        rec_ccp.needs_privilege, rec_ccp.show_in_sale, rec_ccp.returnable, rec_ccp.show_on_web,
        rec_ccp.primary_product_group_id, rec_ccp.product_account_config_id,
        rec_ccp.override_price_and_text_role, rec_ccp.ipc_available, rec_ccp.restriction_type,
        rec_ccp.mapi_selling_points, rec_ccp.mapi_rank, rec_ccp.sales_commission,
        rec_ccp.sales_units, rec_ccp.period_commission, rec_ccp.sold_outside_home_center,
        rec_ccp.show_on_mobile_api, rec_ccp.assigned_staff_group, rec_ccp.print_qr_on_receipt,
        rec_ccp.last_recount_date, rec_ccp.single_use, rec_ccp.flat_rate_commission,
        rec_ccp.webname, prorata.ptype,
        CASE
            WHEN prorata.external_id IS NOT NULL
            THEN 1
            ELSE 0
        END, prorata.income_accountcenter, prorata.income_accountid, prorata.expense_accountcenter,
        prorata.expense_accountid, prorata.refund_accountcenter, prorata.refund_accountid,
        CASE
            WHEN prorata.price > 0
            THEN 1
            ELSE 0
        END, prorata.min_price, prorata.cost_price, prorata.requiredrole,
        CASE
            WHEN prorata.globalid IS NOT NULL
            THEN 1
            ELSE 0
        END , prorata.max_buy_qty, prorata.max_buy_qty_period, prorata.max_buy_qty_period_type,
        prorata.needs_privilege, prorata.show_in_sale, prorata.returnable, prorata.show_on_web,
        prorata.primary_product_group_id, prorata.product_account_config_id,
        prorata.override_price_and_text_role, prorata.ipc_available, prorata.restriction_type,
        prorata.mapi_selling_points, prorata.mapi_rank, prorata.sales_commission,
        prorata.sales_units, prorata.period_commission, prorata.sold_outside_home_center,
        prorata.show_on_mobile_api, prorata.assigned_staff_group, prorata.print_qr_on_receipt,
        prorata.last_recount_date, prorata.single_use, prorata.flat_rate_commission,
        prorata.webname, sub_pgrant.privilege_set, sub_pgrant.punishment,
        sub_pgrant.granter_globalid, sub_pgrant.sponsorship_name, sub_pgrant.sponsorship_amount,
        sub_pgrant.sponsorship_rounding, sub_pgrant.usage_product, sub_pgrant.usage_quantity,
        sub_pgrant.usage_duration_value, sub_pgrant.usage_duration_unit,
        sub_pgrant.usage_duration_round, sub_pgrant.usage_use_at_planning, sub_pgrant.extension,
        cc_pgrant.privilege_set, cc_pgrant.punishment, cc_pgrant.granter_globalid,
        cc_pgrant.sponsorship_name, cc_pgrant.sponsorship_amount, cc_pgrant.sponsorship_rounding,
        cc_pgrant.usage_product, cc_pgrant.usage_quantity, cc_pgrant.usage_duration_value,
        cc_pgrant.usage_duration_unit, cc_pgrant.usage_duration_round,
        cc_pgrant.usage_use_at_planning, cc_pgrant.extension, sub_pset.id, sub_pset.name,
        sub_pset.description, sub_pset.scope_type, sub_pset.scope_id, sub_pset.state,
        sub_pset.blocked_on, sub_pset.privilege_set_groups_id, sub_pset.time_restriction,
        sub_pset.booking_window_restriction, sub_pset.frequency_restriction_count,
        sub_pset.frequency_restriction_value, sub_pset.frequency_restriction_unit,
        sub_pset.frequency_restriction_type, sub_pset.frequency_restr_include_noshow,
        sub_pset.reusable, sub_pset.availability_period_id, sub_pset.multiaccess_window_count,
        sub_pset.multiaccess_window_time_value, sub_pset.multiaccess_window_time_unit,
        sub_pset.multiaccess_window_type, cc_pset.id, cc_pset.name, cc_pset.description,
        cc_pset.scope_type, cc_pset.scope_id, cc_pset.state, cc_pset.blocked_on,
        cc_pset.privilege_set_groups_id, cc_pset.time_restriction,
        cc_pset.booking_window_restriction, cc_pset.frequency_restriction_count,
        cc_pset.frequency_restriction_value, cc_pset.frequency_restriction_unit,
        cc_pset.frequency_restriction_type, cc_pset.frequency_restr_include_noshow,
        cc_pset.reusable, cc_pset.availability_period_id, cc_pset.multiaccess_window_count,
        cc_pset.multiaccess_window_time_value, cc_pset.multiaccess_window_time_unit,
        cc_pset.multiaccess_window_type ) NOT IN
    (
        SELECT
            p_ptype,
            p_external_id,
            p_income_accountcenter,
            p_income_accountid,
            p_expense_accountcenter,
            p_expense_accountid,
            p_refund_accountcenter,
            p_refund_accountid,
            p_price,
            p_min_price,
            p_cost_price,
            p_requiredrole,
            p_globalid,
            p_max_buy_qty,
            p_max_buy_qty_period,
            p_max_buy_qty_period_type,
            p_needs_privilege,
            p_show_in_sale,
            p_returnable,
            p_show_on_web,
            p_primary_product_group_id,
            p_product_account_config_id,
            p_override_price_and_text_role,
            p_ipc_available,
            p_restriction_type,
            p_mapi_selling_points,
            p_mapi_rank,
            p_sales_commission,
            p_sales_units,
            p_period_commission,
            p_sold_outside_home_center,
            p_show_on_mobile_api,
            p_assigned_staff_group,
            p_print_qr_on_receipt,
            p_last_recount_date,
            p_single_use,
            p_flat_rate_commission,
            p_webname,
            pg_id,
            pg_top_node_id,
            pg_scope_type,
            pg_scope_id,
            pg_state,
            pg_parent_product_group_id,
            pg_show_in_shop,
            pg_product_account_config_id,
            pg_colour_group_id,
            pg_ranking,
            pg_in_subscription_sales,
            pg_hide_in_report_parameters,
            pg_exclude_from_member_count,
            pg_exclude_from_product_cleaning,
            pg_client_profile_id,
            pg_external_id,
            pg_single_product_in_basket,
            pg_dimension_product_group_id,
            st_st_type,
            st_use_individual_price,
            st_floatingperiod,
            st_prorataperiodcount,
            st_extend_binding_by_prorata,
            st_initialperiodcount,
            st_extend_binding_by_initial,
            st_bindingperiodcount,
            st_periodunit,
            st_periodcount,
            st_age_restriction_type,
            st_age_restriction_value,
            st_sex_restriction,
            st_freezeperiodproduct_center,
            st_freezestartupproduct_center,
            st_transferproduct_center,
            st_add_on_to_center,
            st_renew_window,
            st_rank,
            st_is_addon_subscription,
            st_prorataproduct_center,
            st_adminfeeproduct_center,
            st_clearing_house_restriction,
            st_is_price_update_excluded,
            st_start_date_limit_count,
            st_start_date_limit_unit,
            st_start_date_restriction,
            st_auto_stop_on_binding_end_date,
            st_roundup_end_unit,
            st_buyoutfeeproduct_center,
            st_rec_clipcard_product_center,
            st_autorenew_binding_count,
            st_autorenew_binding_unit,
            st_autorenew_binding_notice_count,
            st_autorenew_binding_notice_unit,
            st_sale_startup_clipcard,
            st_unrestricted_freeze_allowed,
            st_buyout_fee_percentage,
            st_change_requiredrole,
            st_reactivation_allowed,
            st_can_be_reassigned,
            st_rec_clipcard_pack_size,
            rec_ccp_ptype,
            rec_ccp_external_id,
            rec_ccp_income_accountcenter,
            rec_ccp_income_accountid,
            rec_ccp_expense_accountcenter,
            rec_ccp_expense_accountid,
            rec_ccp_refund_accountcenter,
            rec_ccp_refund_accountid,
            rec_ccp_price,
            rec_ccp_min_price,
            rec_ccp_cost_price,
            rec_ccp_requiredrole,
            rec_ccp_globalid,
            rec_ccp_max_buy_qty,
            rec_ccp_max_buy_qty_period,
            rec_ccp_max_buy_qty_period_type,
            rec_ccp_needs_privilege,
            rec_ccp_show_in_sale,
            rec_ccp_returnable,
            rec_ccp_show_on_web,
            rec_ccp_primary_product_group_id,
            rec_ccp_product_account_config_id,
            rec_ccp_override_price_and_text_role,
            rec_ccp_ipc_available,
            rec_ccp_restriction_type,
            rec_ccp_mapi_selling_points,
            rec_ccp_mapi_rank,
            rec_ccp_sales_commission,
            rec_ccp_sales_units,
            rec_ccp_period_commission,
            rec_ccp_sold_outside_home_center,
            rec_ccp_show_on_mobile_api,
            rec_ccp_assigned_staff_group,
            rec_ccp_print_qr_on_receipt,
            rec_ccp_last_recount_date,
            rec_ccp_single_use,
            rec_ccp_flat_rate_commission,
            rec_ccp_webname,
            prorata_ptype,
            prorata_external_id,
            prorata_income_accountcenter,
            prorata_income_accountid,
            prorata_expense_accountcenter,
            prorata_expense_accountid,
            prorata_refund_accountcenter,
            prorata_refund_accountid,
            prorata_price,
            prorata_min_price,
            prorata_cost_price,
            prorata_requiredrole,
            prorata_globalid,
            prorata_max_buy_qty,
            prorata_max_buy_qty_period,
            prorata_max_buy_qty_period_type,
            prorata_needs_privilege,
            prorata_show_in_sale,
            prorata_returnable,
            prorata_show_on_web,
            prorata_primary_product_group_id,
            prorata_product_account_config_id,
            prorata_override_price_and_text_role,
            prorata_ipc_available,
            prorata_restriction_type,
            prorata_mapi_selling_points,
            prorata_mapi_rank,
            prorata_sales_commission,
            prorata_sales_units,
            prorata_period_commission,
            prorata_sold_outside_home_center,
            prorata_show_on_mobile_api,
            prorata_assigned_staff_group,
            prorata_print_qr_on_receipt,
            prorata_last_recount_date,
            prorata_single_use,
            prorata_flat_rate_commission,
            prorata_webname,
            sub_pgrant.privilege_set,
            sub_pgrant.punishment,
            sub_pgrant.granter_globalid,
            sub_pgrant.sponsorship_name,
            sub_pgrant.sponsorship_amount,
            sub_pgrant.sponsorship_rounding,
            sub_pgrant.usage_product,
            sub_pgrant.usage_quantity,
            sub_pgrant.usage_duration_value,
            sub_pgrant.usage_duration_unit,
            sub_pgrant.usage_duration_round,
            sub_pgrant.usage_use_at_planning,
            sub_pgrant.extension,
            cc_pgrant.privilege_set,
            cc_pgrant.punishment,
            cc_pgrant.granter_globalid,
            cc_pgrant.sponsorship_name,
            cc_pgrant.sponsorship_amount,
            cc_pgrant.sponsorship_rounding,
            cc_pgrant.usage_product,
            cc_pgrant.usage_quantity,
            cc_pgrant.usage_duration_value,
            cc_pgrant.usage_duration_unit,
            cc_pgrant.usage_duration_round,
            cc_pgrant.usage_use_at_planning,
            cc_pgrant.extension,
            sub_pset.id,
            sub_pset.name,
            sub_pset.description,
            sub_pset.scope_type,
            sub_pset.scope_id,
            sub_pset.state,
            sub_pset.blocked_on,
            sub_pset.privilege_set_groups_id,
            sub_pset.time_restriction,
            sub_pset.booking_window_restriction,
            sub_pset.frequency_restriction_count,
            sub_pset.frequency_restriction_value,
            sub_pset.frequency_restriction_unit,
            sub_pset.frequency_restriction_type,
            sub_pset.frequency_restr_include_noshow,
            sub_pset.reusable,
            sub_pset.availability_period_id,
            sub_pset.multiaccess_window_count,
            sub_pset.multiaccess_window_time_value,
            sub_pset.multiaccess_window_time_unit,
            sub_pset.multiaccess_window_type,
            cc_pset.id,
            cc_pset.name,
            cc_pset.description,
            cc_pset.scope_type,
            cc_pset.scope_id,
            cc_pset.state,
            cc_pset.blocked_on,
            cc_pset.privilege_set_groups_id,
            cc_pset.time_restriction,
            cc_pset.booking_window_restriction,
            cc_pset.frequency_restriction_count,
            cc_pset.frequency_restriction_value,
            cc_pset.frequency_restriction_unit,
            cc_pset.frequency_restriction_type,
            cc_pset.frequency_restr_include_noshow,
            cc_pset.reusable,
            cc_pset.availability_period_id,
            cc_pset.multiaccess_window_count,
            cc_pset.multiaccess_window_time_value,
            cc_pset.multiaccess_window_time_unit,
            cc_pset.multiaccess_window_type
        FROM
            baseline) ;   

