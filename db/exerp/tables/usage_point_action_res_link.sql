CREATE TABLE 
    usage_point_action_res_link 
    ( 
        action_center int4 NOT NULL, 
        action_id int4 NOT NULL, 
        resource_center int4 NOT NULL, 
        resource_id int4 NOT NULL, 
        PRIMARY KEY (action_center, action_id, resource_center, resource_id), 
        CONSTRAINT uparl_to_resource_fk FOREIGN KEY (resource_center, resource_id) REFERENCES 
        "exerp"."booking_resources" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT uparl_to_action_fk FOREIGN KEY (action_center, action_id) REFERENCES 
    "exerp"."usage_point_resources" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
