WITH
    baseline AS
    (
        SELECT
            -------------------------------
            -------for activity table
            a1.top_node_id       AS a_top_node_id,
            a1.scope_type        AS a_scope_type,
            a1.scope_id          AS a_scope_id,
            a1.activity_group_id AS a_activity_group_id,
            CASE
                WHEN a1.colour_group_id > 0
                THEN 1
                ELSE 0
            END "a_colour_group_id",
            CASE
                WHEN a1.max_participants > 0
                THEN 1
                ELSE 0
            END                     "a_max_participants",
            a1.requires_planning              AS a_requires_planning,
            a1.allow_name_override            AS a_allow_name_override,
            a1.allow_recurring_bookings       AS a_allow_recurring_bookings,
            a1.override_staff_configs         AS a_override_staff_configs,
            a1.override_participation_configs AS a_override_participation_configs,
            a1.override_time_config           AS a_override_time_config,
            a1.time_config_id                 AS a_time_config_id,
            a1.energy_consumption_kcal_hour   AS a_energy_consumption_kcal_hour,
            a1.seat_booking_support_type      AS a_seat_booking_support_type,
            a1.headcount_manual_adjustment    AS a_headcount_manual_adjustment,
            a1.available_from                 AS a_available_from,
            a1.available_to                   AS a_available_to,
            a1.print_showup_receipt           AS a_print_showup_receipt,
            a1.allow_overlapping_bookings     AS a_allow_overlapping_bookings,
            a1.age_restriction_on_bookings    AS a_age_restriction_on_bookings,
            -------------------------------
            -------for activity_group table
            ag1.top_node_id                   AS ag_top_node_id,
            ag1.scope_type                    AS ag_scope_type,
            ag1.scope_id                      AS ag_scope_id,
            ag1.public_participation          AS ag_public_participation,
            ag1.bookable_via_mobile_api       AS ag_bookable_via_mobile_api,
            ag1.bookable_on_frontdesk_app     AS ag_bookable_on_frontdesk_app,
            ag1.create_booking_role           AS ag_create_booking_role,
            ag1.edit_booking_role             AS ag_edit_booking_role,
            ag1.cancel_booking_role           AS ag_cancel_booking_role,
            ag1.handle_multiple_bookings_role AS ag_handle_multiple_bookings_role,
            ag1.override_description          AS ag_override_description,
            ag1.showup_by_qrcode              AS ag_showup_by_qrcode,
            ag1.showup_by_mobile_api          AS ag_showup_by_mobile_api,
            ag1.supports_substitution_flag    AS ag_supports_substitution_flag,
            ag1.wait_list_cap_perc            AS ag_wait_list_cap_perc,
            ag1.indicate_new_members          AS ag_indicate_new_members,
            ag1.parent_activity_group_id      AS ag_parent_activity_group_id,
            -------------------------------
            -------for activity_staff_configurations table
            CASE
                WHEN acs1.staff_group_id > 0
                THEN 1
                ELSE 0
            END                    "acs_staff_group_id",
            acs1.minimum_staffs  AS acs_minimum_staffs,
            acs1.maximum_staffs  AS acs_maximum_staffs,
            acs1.staff_anonymity AS acs_staff_anonymity,
            -------------------------------
            -------for participation_configurations table
            bpg1.scope_type                     AS bpg_scope_type,
            bpg1.scope_id                       AS bpg_scope_id,
            bpg1.converted_rr_type              AS bpg_converted_rr_type,
            bpg1.frequency_restriction_count    AS bpg_frequency_restriction_count,
            bpg1.frequency_restriction_value    AS bpg_frequency_restriction_value,
            bpg1.frequency_restriction_unit     AS bpg_frequency_restriction_unit,
            bpg1.frequency_restriction_type     AS bpg_frequency_restriction_type,
            bpg1.frequency_restr_include_noshow AS bpg_frequency_restr_include_noshow,
            CASE
                WHEN bpg1.id > 0
                THEN 1
                ELSE 0
            END "bgp_access_group"
        FROM
            activity a1
        JOIN
            activity_group ag1
        ON
            a1.activity_group_id = ag1.id
        JOIN
            activity_staff_configurations acs1
        ON
            acs1.activity_id = a1.id
        JOIN
            participation_configurations pc1
        ON
            a1.id = pc1.activity_id
        AND pc1.name IN ('Class',
                         'Customer')
        LEFT JOIN
            booking_privilege_groups bpg1
        ON
            pc1.access_group_id = bpg1.id
            ----------------------------------
            ----------------------------------
            ----SET THE BASELINE ACTIVITY-----
        WHERE
            a1.id = :baseline_activityid
			and a1.state = 'ACTIVE'
    )
SELECT
    -------------ACTIVITY
    a.id,
    a.top_node_id,
    a.scope_type,
    a.scope_id,
    a.activity_group_id,
    CASE
        WHEN a.colour_group_id > 0
        THEN 1
        ELSE 0
    END AS calc_colour_group_id,
    CASE
        WHEN acs.staff_group_id > 0
        THEN 1
        ELSE 0
    END AS max_participant_calc_value,
    a.requires_planning,
    a.allow_name_override,
    a.allow_recurring_bookings,
    a.override_staff_configs,
    a.override_participation_configs,
    a.override_time_config,
    a.time_config_id,
    a.energy_consumption_kcal_hour,
    a.seat_booking_support_type,
    a.headcount_manual_adjustment,
    a.available_from,
    a.available_to,
    a.print_showup_receipt,
    a.allow_overlapping_bookings,
    a.age_restriction_on_bookings,
    -------------ACTIVITY_GROUP
    ag.top_node_id,
    ag.scope_type,
    ag.scope_id,
    ag.public_participation,
    ag.bookable_via_mobile_api,
    ag.bookable_on_frontdesk_app,
    ag.create_booking_role,
    ag.edit_booking_role,
    ag.cancel_booking_role,
    ag.handle_multiple_bookings_role,
    ag.override_description,
    ag.showup_by_qrcode,
    ag.showup_by_mobile_api,
    ag.supports_substitution_flag,
    ag.wait_list_cap_perc,
    ag.indicate_new_members,
    ag.parent_activity_group_id,
    -------------ACTIVITY_STAFF_CONFIGURATIONS
    CASE
        WHEN acs.staff_group_id > 0
        THEN 1
        ELSE 0
    END AS max_staffgrp_id_calc_value,
    acs.minimum_staffs,
    acs.maximum_staffs,
    acs.staff_anonymity,
    -------------BOOKING_PRIVILEGE_GROUPS
    bpg.scope_type,
    bpg.scope_id,
    bpg.converted_rr_type,
    bpg.frequency_restriction_count,
    bpg.frequency_restriction_value,
    bpg.frequency_restriction_unit,
    bpg.frequency_restriction_type,
    bpg.frequency_restr_include_noshow,
    CASE
        WHEN bpg.id > 0
        THEN 1
        ELSE 0
    END AS bgp_calc_access_group
FROM
    activity a
JOIN
    activity_group ag
ON
    a.activity_group_id = ag.id
JOIN
    activity_staff_configurations acs
ON
    acs.activity_id = a.id
JOIN
    participation_configurations pc
ON
    a.id = pc.activity_id
AND pc.name IN ('Class',
                'Customer')
LEFT JOIN
    booking_privilege_groups bpg
ON
    pc.access_group_id = bpg.id
    ----------------------------------------
    ----------------------------------------
    ----SET THE BASELINE ACTIVITY GROUP-----
WHERE
    a.activity_group_id = :activitygroup
	and a.state = 'ACTIVE'
AND (
        a.top_node_id, a.scope_type, a.scope_id, a.activity_group_id,
        CASE
            WHEN a.colour_group_id > 0
            THEN 1
            ELSE 0
        END,
        CASE
            WHEN a.max_participants > 0
            THEN 1
            ELSE 0
        END, a.requires_planning, a.allow_name_override, a.allow_recurring_bookings,
        a.override_staff_configs, a.override_participation_configs, a.override_time_config,
        a.time_config_id, a.energy_consumption_kcal_hour, a.seat_booking_support_type,
        a.headcount_manual_adjustment, a.available_from, a.available_to, a.print_showup_receipt,
        a.allow_overlapping_bookings, a.age_restriction_on_bookings, ag.top_node_id, ag.scope_type,
        ag.scope_id, ag.public_participation, ag.bookable_via_mobile_api,
        ag.bookable_on_frontdesk_app, ag.create_booking_role, ag.edit_booking_role,
        ag.cancel_booking_role, ag.handle_multiple_bookings_role, ag.override_description,
        ag.showup_by_qrcode, ag.showup_by_mobile_api, ag.supports_substitution_flag,
        ag.wait_list_cap_perc, ag.indicate_new_members, ag.parent_activity_group_id,
        CASE
            WHEN acs.staff_group_id > 0
            THEN 1
            ELSE 0
        END, acs.minimum_staffs, acs.maximum_staffs, acs.staff_anonymity, bpg.scope_type,
        bpg.scope_id, bpg.converted_rr_type, bpg.frequency_restriction_count,
        bpg.frequency_restriction_value, bpg.frequency_restriction_unit,
        bpg.frequency_restriction_type, bpg.frequency_restr_include_noshow,
        CASE
            WHEN bpg.id > 0
            THEN 1
            ELSE 0
        END ) NOT IN
    (
        SELECT
            a_top_node_id,
            a_scope_type,
            a_scope_id,
            a_activity_group_id,
            a_colour_group_id,
            a_max_participants,
            a_requires_planning,
            a_allow_name_override,
            a_allow_recurring_bookings,
            a_override_staff_configs,
            a_override_participation_configs,
            a_override_time_config,
            a_time_config_id,
            a_energy_consumption_kcal_hour,
            a_seat_booking_support_type,
            a_headcount_manual_adjustment,
            a_available_from,
            a_available_to,
            a_print_showup_receipt,
            a_allow_overlapping_bookings,
            a_age_restriction_on_bookings,
            ag_top_node_id,
            ag_scope_type,
            ag_scope_id,
            ag_public_participation,
            ag_bookable_via_mobile_api,
            ag_bookable_on_frontdesk_app,
            ag_create_booking_role,
            ag_edit_booking_role,
            ag_cancel_booking_role,
            ag_handle_multiple_bookings_role,
            ag_override_description,
            ag_showup_by_qrcode,
            ag_showup_by_mobile_api,
            ag_supports_substitution_flag,
            ag_wait_list_cap_perc,
            ag_indicate_new_members,
            ag_parent_activity_group_id,
            acs_staff_group_id,
            acs_minimum_staffs,
            acs_maximum_staffs,
            acs_staff_anonymity,
            bpg_scope_type,
            bpg_scope_id,
            bpg_converted_rr_type,
            bpg_frequency_restriction_count,
            bpg_frequency_restriction_value,
            bpg_frequency_restriction_unit,
            bpg_frequency_restriction_type,
            bpg_frequency_restr_include_noshow,
            bgp_access_group
        FROM
            baseline) ;   