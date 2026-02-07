CREATE TABLE 
    roles 
    ( 
        id int4 NOT NULL, 
        rolename text(2147483647) NOT NULL, 
        masterroleid int4, 
        scope_type text(2147483647), 
        scope_id int4, 
        blocked bool, 
        config_type text(2147483647), 
        description text(2147483647), 
        system_id int4, 
        is_action bool DEFAULT FALSE NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT fk_ro_role FOREIGN KEY (masterroleid) REFERENCES "exerp"."roles" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
