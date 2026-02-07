CREATE TABLE 
    privilege_sets 
    ( 
        id int4 NOT NULL, 
        name        text(2147483647) NOT NULL, 
        description text(2147483647), 
        scope_type  text(2147483647), 
        scope_id int4, 
        STATE text(2147483647) DEFAULT 'ACTIVE'::text NOT NULL, 
        blocked_on int8, 
        privilege_set_groups_id int4, 
        time_restriction bytea, 
        booking_window_restriction bytea, 
        frequency_restriction_count int4, 
        frequency_restriction_value int4, 
        frequency_restriction_unit int4, 
        frequency_restriction_type int4, 
        frequency_restr_include_noshow bool DEFAULT FALSE NOT NULL, 
        reusable bool DEFAULT FALSE NOT NULL, 
        availability_period_id int4, 
        multiaccess_window_count int4, 
        multiaccess_window_time_value int4, 
        multiaccess_window_time_unit int4, 
        multiaccess_window_type int4, 
        PRIMARY KEY (id) 
    );
