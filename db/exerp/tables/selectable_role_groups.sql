CREATE TABLE 
    selectable_role_groups 
    ( 
        role_id int4 NOT NULL, 
        group_purpose_id int4 NOT NULL, 
        PRIMARY KEY (group_purpose_id, role_id), 
        CONSTRAINT srg_to_role_fk FOREIGN KEY (role_id) REFERENCES "exerp"."roles" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
