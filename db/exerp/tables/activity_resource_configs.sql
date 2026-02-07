CREATE TABLE 
    activity_resource_configs 
    ( 
        id int4 NOT NULL, 
        activity_id int4, 
        name text(2147483647) NOT NULL, 
        booking_resource_group_id int4, 
        parent_activity_key int4, 
        resource_group_selection int4 DEFAULT 0 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT act_res_conf_to_par_act_fk FOREIGN KEY (parent_activity_key) REFERENCES 
        "exerp"."activity" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT act_res_config_to_activity_fk FOREIGN KEY (activity_id) REFERENCES 
    "exerp"."activity" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
