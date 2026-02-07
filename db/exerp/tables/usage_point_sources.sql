CREATE TABLE 
    usage_point_sources 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        usage_point_center int4, 
        usage_point_id int4, 
        client_id int4, 
        reader_device_id int4, 
        reader_device_sub_id text(2147483647), 
        action_center int4, 
        action_id int4, 
        external_id VARCHAR(100), 
        PRIMARY KEY (center, id), 
        CONSTRAINT ups_to_client_fk FOREIGN KEY (client_id) REFERENCES "exerp"."clients" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ups_to_device_fk FOREIGN KEY (reader_device_id) REFERENCES "exerp"."devices" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ups_to_up_fk FOREIGN KEY (usage_point_center, usage_point_id) REFERENCES 
    "exerp"."usage_points" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
