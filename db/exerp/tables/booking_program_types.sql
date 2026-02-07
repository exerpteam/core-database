CREATE TABLE 
    booking_program_types 
    ( 
        id int4 NOT NULL, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        name        text(2147483647), 
        STATE       VARCHAR(10) DEFAULT 'NULL::character varying', 
        type        VARCHAR(10) DEFAULT 'COURSE'::character VARYING, 
        description VARCHAR(2000), 
        time_config_id int4, 
        age_group_id int4, 
        single_days_booking_enabled bool DEFAULT FALSE, 
        single_days_from_unit int4, 
        single_days_from_value int4, 
        availability VARCHAR(2000), 
        definition_key int4, 
        override_name bool DEFAULT TRUE NOT NULL, 
        override_age_group_id bool DEFAULT TRUE NOT NULL, 
        override_single_days_config bool DEFAULT TRUE NOT NULL, 
        full_camp_product_global_id VARCHAR(30), 
        documentation_setting_id int4, 
        standby_list_size int4, 
        available_on_web bool DEFAULT TRUE NOT NULL, 
        override_available_on_web bool DEFAULT TRUE NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT bpt_to_time_config_fk FOREIGN KEY (time_config_id) REFERENCES 
        "exerp"."booking_time_configs" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
