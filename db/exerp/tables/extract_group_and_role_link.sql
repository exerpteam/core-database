CREATE TABLE 
    extract_group_and_role_link 
    ( 
        extract_group_id int4 NOT NULL, 
        role_id int4 NOT NULL, 
        PRIMARY KEY (extract_group_id, role_id), 
        CONSTRAINT ext_grp_and_role_to_ext_grp_fk FOREIGN KEY (extract_group_id) REFERENCES 
        "exerp"."extract_group" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ext_grp_and_role_to_role_fk FOREIGN KEY (role_id) REFERENCES "exerp"."roles" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
