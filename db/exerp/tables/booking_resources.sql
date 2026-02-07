CREATE TABLE 
    booking_resources 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        name text(2147483647) NOT NULL, 
        attendable bool DEFAULT FALSE NOT NULL, 
        show_calendar bool DEFAULT FALSE NOT NULL, 
        attend_privilege_id int4, 
        attend_availability bytea, 
        STATE    text(2147483647) NOT NULL, 
        type     text(2147483647) NOT NULL, 
        vertices text(2147483647), 
        override_center_opening_hours bool DEFAULT FALSE NOT NULL, 
        coment      text(2147483647), 
        external_id text(2147483647), 
        sex_restriction int4 DEFAULT 0 NOT NULL, 
        age_restriction_type int4 DEFAULT 0 NOT NULL, 
        age_restriction_value int4 DEFAULT 0 NOT NULL, 
        ext_attr_config bytea, 
        availability_staff bytea, 
        instructor_x NUMERIC(0,0), 
        instructor_y NUMERIC(0,0), 
        attend_availability_period_id int4, 
        staff_availability_period_id int4, 
        api_ignore__check_in bool DEFAULT FALSE, 
        api_check_out bool DEFAULT FALSE, 
        last_modified int8, 
        age_restriction_min_value int4, 
        age_restriction_max_value int4, 
        webname VARCHAR(1024), 
        PRIMARY KEY (center, id), 
        CONSTRAINT book_res_to_attend_priv_fk FOREIGN KEY (attend_privilege_id) REFERENCES 
        "exerp"."booking_privilege_groups" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
