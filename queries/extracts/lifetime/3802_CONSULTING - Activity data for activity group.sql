SELECT
    ag.name AS activitygroup,
    ag.id   AS activitygroup_id,
    a.name  AS ActivityName,
    a.id    AS Activity_id,
    a.state,
    CASE
        WHEN a.activity_type = 2
        THEN 'Class'
        WHEN a.activity_type = 3
        THEN 'Resource booking'
        WHEN a.activity_type = 4
        THEN 'Staff booking'
        WHEN a.activity_type = 9
        THEN 'Course'
        ELSE NULL
    END AS activitytype,
    -------------ACTIVITY
    a.id,
    a.top_node_id,
    a.scope_type,
    a.scope_id,
    a.activity_group_id,
    a.colour_group_id,
    a.max_participants,
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
    acs.staff_group_id,
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
    bpg.id
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
WHERE
    a.state = 'ACTIVE'
AND ag.id = :activitygroupid
ORDER BY
    ag.name,
    a.name,
    activitytype ;
