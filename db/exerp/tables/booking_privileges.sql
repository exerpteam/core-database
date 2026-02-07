CREATE TABLE 
    booking_privileges 
    ( 
        id int4 NOT NULL, 
        privilege_set int4, 
        valid_for text(2147483647) NOT NULL, 
        valid_from int8, 
        valid_to int8, 
        group_id int4 NOT NULL, 
        max_open int4, 
        time_conf bytea, 
        tentative_only bool, 
        cutoff_time_setting_id int4, 
        in_advance_threshold int4, 
        requires_manual_selection bool, 
        PRIMARY KEY (id), 
        CONSTRAINT book_priv_to_priv_group FOREIGN KEY (group_id) REFERENCES 
        "exerp"."booking_privilege_groups" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT book_priv_to_priv_set FOREIGN KEY (privilege_set) REFERENCES 
    "exerp"."privilege_sets" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
