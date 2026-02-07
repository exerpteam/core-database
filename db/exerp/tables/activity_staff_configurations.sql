CREATE TABLE 
    activity_staff_configurations 
    ( 
        id int4 NOT NULL, 
        activity_id int4, 
        name text(2147483647) NOT NULL, 
        excluzive bool NOT NULL, 
        staff_group_id int4, 
        minimum_staffs int4 NOT NULL, 
        maximum_staffs int4 NOT NULL, 
        staff_anonymity text(2147483647) NOT NULL, 
        parent_activity_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT act_staff_conf_to_par_act_fk FOREIGN KEY (parent_activity_id) REFERENCES 
        "exerp"."activity" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT activ_staff_config_to_activ_fk FOREIGN KEY (activity_id) REFERENCES 
    "exerp"."activity" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT act_staff_conf_to_staff_grp_fk FOREIGN KEY (staff_group_id) REFERENCES 
    "exerp"."staff_groups" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
