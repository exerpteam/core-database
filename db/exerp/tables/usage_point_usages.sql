CREATE TABLE 
    usage_point_usages 
    ( 
        action_center int4 NOT NULL, 
        action_id int4 NOT NULL, 
        person_center int4 NOT NULL, 
        person_id int4 NOT NULL, 
        TIME int8 NOT NULL, 
        PRIMARY KEY (action_center, action_id, person_center, person_id), 
        CONSTRAINT upu_to_per_fk FOREIGN KEY (person_center, person_id) REFERENCES 
        "exerp"."persons" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT upu_to_upa_fk FOREIGN KEY (action_center, action_id) REFERENCES 
    "exerp"."usage_point_resources" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
