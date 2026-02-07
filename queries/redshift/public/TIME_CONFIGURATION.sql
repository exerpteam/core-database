SELECT
    booking_time_configs.id   AS "ID",
    booking_time_configs.name AS "NAME",
    part_start_value          AS "PART_FROM",
    CASE
        WHEN part_start_unit = 0
        THEN 'WEEK'
        WHEN part_start_unit = 1
        THEN 'DAY'
        WHEN part_start_unit = 2
        THEN 'MONTH'
        WHEN part_start_unit = 3
        THEN 'YEAR'
        WHEN part_start_unit = 4
        THEN 'HOUR'
        WHEN part_start_unit = 5
        THEN 'MINUTE'
        WHEN part_start_unit = 6
        THEN 'SECOND'
    END                   AS "PART_FROM_UNIT",
    part_start_round as "PART_FROM_ROUND",
    part_stop_staff_value AS "PART_STAFF_STOP",
    CASE
        WHEN part_stop_staff_unit = 0
        THEN 'WEEK'
        WHEN part_stop_staff_unit = 1
        THEN 'DAY'
        WHEN part_stop_staff_unit = 2
        THEN 'MONTH'
        WHEN part_stop_staff_unit = 3
        THEN 'YEAR'
        WHEN part_stop_staff_unit = 4
        THEN 'HOUR'
        WHEN part_stop_staff_unit = 5
        THEN 'MINUTE'
        WHEN part_stop_staff_unit = 6
        THEN 'SECOND'
    END                 AS "PART_STAFF_STOP_UNIT",
    part_stop_staff_round as "PART_STAFF_STOP_ROUND",
    part_stop_cus_value AS "PART_CUST_STOP",
    CASE
        WHEN part_stop_cus_unit = 0
        THEN 'WEEK'
        WHEN part_stop_cus_unit = 1
        THEN 'DAY'
        WHEN part_stop_cus_unit = 2
        THEN 'MONTH'
        WHEN part_stop_cus_unit = 3
        THEN 'YEAR'
        WHEN part_stop_cus_unit = 4
        THEN 'HOUR'
        WHEN part_stop_cus_unit = 5
        THEN 'MINUTE'
        WHEN part_stop_cus_unit = 6
        THEN 'SECOND'
    END                          AS "PART_CUST_STOP_UNIT",
    part_stop_cus_round AS "PART_CUST_STOP_ROUND",
    part_cancel_sanc_start_value AS "CANCEL_SANC_START",
    CASE
        WHEN part_cancel_sanc_start_unit = 0
        THEN 'WEEK'
        WHEN part_cancel_sanc_start_unit = 1
        THEN 'DAY'
        WHEN part_cancel_sanc_start_unit = 2
        THEN 'MONTH'
        WHEN part_cancel_sanc_start_unit = 3
        THEN 'YEAR'
        WHEN part_cancel_sanc_start_unit = 4
        THEN 'HOUR'
        WHEN part_cancel_sanc_start_unit = 5
        THEN 'MINUTE'
        WHEN part_cancel_sanc_start_unit = 6
        THEN 'SECOND'
    END                          AS "CANCEL_SANC_START_UNIT",
    part_cancel_sanc_start_round as "CANCEL_SANC_START_ROUND",
    part_cancel_stop_staff_value AS "CANCEL_STOP_STAFF",
    CASE
        WHEN part_cancel_stop_staff_unit = 0
        THEN 'WEEK'
        WHEN part_cancel_stop_staff_unit = 1
        THEN 'DAY'
        WHEN part_cancel_stop_staff_unit = 2
        THEN 'MONTH'
        WHEN part_cancel_stop_staff_unit = 3
        THEN 'YEAR'
        WHEN part_cancel_stop_staff_unit = 4
        THEN 'HOUR'
        WHEN part_cancel_stop_staff_unit = 5
        THEN 'MINUTE'
        WHEN part_cancel_stop_staff_unit = 6
        THEN 'SECOND'
    END                        AS "CANCEL_STOP_STAFF_UNIT",
    part_cancel_stop_staff_round AS "CANCEL_STOP_STAFF_ROUND",
    part_cancel_stop_cus_value AS "CANCEL_STOP_CUST",
    CASE
        WHEN part_cancel_stop_cus_unit = 0
        THEN 'WEEK'
        WHEN part_cancel_stop_cus_unit = 1
        THEN 'DAY'
        WHEN part_cancel_stop_cus_unit = 2
        THEN 'MONTH'
        WHEN part_cancel_stop_cus_unit = 3
        THEN 'YEAR'
        WHEN part_cancel_stop_cus_unit = 4
        THEN 'HOUR'
        WHEN part_cancel_stop_cus_unit = 5
        THEN 'MINUTE'
        WHEN part_cancel_stop_cus_unit = 6
        THEN 'SECOND'
    END                           AS "CANCEL_STOP_CUST_UNIT",
    part_cancel_stop_cus_round AS "CANCEL_STOP_CUST_ROUND",
    part_recurrence_in_past_value AS "RECURRENCE_IN_PAST",
    CASE
        WHEN part_recurrence_in_past_unit = 0
        THEN 'WEEK'
        WHEN part_recurrence_in_past_unit = 1
        THEN 'DAY'
        WHEN part_recurrence_in_past_unit = 2
        THEN 'MONTH'
        WHEN part_recurrence_in_past_unit = 3
        THEN 'YEAR'
        WHEN part_recurrence_in_past_unit = 4
        THEN 'HOUR'
        WHEN part_recurrence_in_past_unit = 5
        THEN 'MINUTE'
        WHEN part_recurrence_in_past_unit = 6
        THEN 'SECOND'
    END                 AS "RECURRENCE_IN_PAST_UNIT",
    part_recurrence_in_past_round AS "RECURRENCE_IN_PAST_ROUND",
    program_early_start_value AS "PROGRAM_START_SIGN_UP",
    CASE
        WHEN program_early_start_unit = 0
        THEN 'WEEK'
        WHEN program_early_start_unit = 1
        THEN 'DAY'
        WHEN program_early_start_unit = 2
        THEN 'MONTH'
        WHEN program_early_start_unit = 3
        THEN 'YEAR'
        WHEN program_early_start_unit = 4
        THEN 'HOUR'
        WHEN program_early_start_unit = 5
        THEN 'MINUTE'
        WHEN program_early_start_unit = 6
        THEN 'SECOND'
    END                   AS "PROGRAM_START_SIGN_UP_UNIT",
    program_early_start_round AS "PROGRAM_START_SIGN_UP_ROUND",
    
    program_signup_value AS "PROGRAM_STOP_SIGN_UP",
    CASE
        WHEN program_signup_unit = 0
        THEN 'WEEK'
        WHEN program_signup_unit = 1
        THEN 'DAY'
        WHEN program_signup_unit = 2
        THEN 'MONTH'
        WHEN program_signup_unit = 3
        THEN 'YEAR'
        WHEN program_signup_unit = 4
        THEN 'HOUR'
        WHEN program_signup_unit = 5
        THEN 'MINUTE'
        WHEN program_signup_unit = 6
        THEN 'SECOND'
    END                   AS "PROGRAM_STOP_SIGN_UP_UNIT",
    program_signup_round AS "PROGRAM_STOP_SIGN_UP_ROUND",
    
    program_cancel_stop_value AS "PROGRAM_STOP_PARTICIPATION_CANCEL",
    CASE
        WHEN program_cancel_stop_unit = 0
        THEN 'WEEK'
        WHEN program_cancel_stop_unit = 1
        THEN 'DAY'
        WHEN program_cancel_stop_unit = 2
        THEN 'MONTH'
        WHEN program_cancel_stop_unit = 3
        THEN 'YEAR'
        WHEN program_cancel_stop_unit = 4
        THEN 'HOUR'
        WHEN program_cancel_stop_unit = 5
        THEN 'MINUTE'
        WHEN program_cancel_stop_unit = 6
        THEN 'SECOND'
    END                   AS "PROGRAM_STOP_PARTICIPATION_CANCEL_UNIT",
    program_cancel_stop_round AS "PROGRAM_STOP_PARTICIPATION_CANCEL_ROUND",
    
    program_latest_start_value AS "PROGRAM_STOP_SIGN_UP_AFTER_PROGRAM_START",
    CASE
        WHEN program_latest_start_unit = 0
        THEN 'WEEK'
        WHEN program_latest_start_unit = 1
        THEN 'DAY'
        WHEN program_latest_start_unit = 2
        THEN 'MONTH'
        WHEN program_latest_start_unit = 3
        THEN 'YEAR'
        WHEN program_latest_start_unit = 4
        THEN 'HOUR'
        WHEN program_latest_start_unit = 5
        THEN 'MINUTE'
        WHEN program_latest_start_unit = 6
        THEN 'SECOND'
    END                   AS "PROGRAM_STOP_SIGN_UP_AFTER_PROGRAM_START_UNIT",
    program_latest_start_round AS "PROGRAM_STOP_SIGN_UP_AFTER_PROGRAM_START_ROUND"
FROM
    booking_time_configs