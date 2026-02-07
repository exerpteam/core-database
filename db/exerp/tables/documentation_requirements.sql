CREATE TABLE 
    documentation_requirements 
    ( 
        id int4 NOT NULL, 
        documentation_setting_key int4 NOT NULL, 
        source_key int4, 
        source_center int4, 
        source_id int4, 
        source_sub_id int4, 
        source_owner_center int4 NOT NULL, 
        source_owner_id int4 NOT NULL, 
        STATE VARCHAR(20) NOT NULL, 
        creation_time int8 NOT NULL, 
        completion_time int8, 
        documentation_setting_type VARCHAR(20) NOT NULL, 
        is_needed bool, 
        last_modified int8, 
        PRIMARY KEY (id), 
        CONSTRAINT doc_req_to_doc_setting_fk FOREIGN KEY (documentation_setting_key) REFERENCES 
        "exerp"."documentation_settings" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT doc_req_to_source_owner_fk FOREIGN KEY (source_owner_center, source_owner_id) 
    REFERENCES "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
