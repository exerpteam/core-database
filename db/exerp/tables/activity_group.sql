CREATE TABLE 
    activity_group 
    ( 
        id int4 NOT NULL, 
        top_node_id int4, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        name  text(2147483647), 
        STATE text(2147483647) NOT NULL, 
        old_activity_type_id int4, 
        public_participation bool, 
        bookable_in_kiosk bool, 
        bookable_on_web bool, 
        bookable_via_api bool, 
        bookable_via_mobile_api bool, 
        bookable_on_frontdesk_app bool, 
        create_booking_role int4, 
        edit_booking_role int4, 
        cancel_booking_role int4, 
        handle_multiple_bookings_role int4, 
        override_description bool DEFAULT FALSE NOT NULL, 
        description bytea, 
        showup_by_qrcode bool DEFAULT FALSE, 
        showup_by_mobile_api bool DEFAULT FALSE NOT NULL, 
        supports_substitution_flag bool DEFAULT FALSE NOT NULL, 
        wait_list_cap_perc int4, 
        override_wait_list_cap_perc bool DEFAULT FALSE NOT NULL, 
        indicate_new_members bool DEFAULT FALSE, 
        parent_activity_group_id int4, 
        external_id VARCHAR(50), 
        last_modified int8, 
        availability_period_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT act_grp_to_parent_act_grp_fk FOREIGN KEY (parent_activity_group_id) REFERENCES 
        "exerp"."activity_group" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
