CREATE TABLE 
    masterproductgroups 
    ( 
        id int4 NOT NULL, 
        globalid text(2147483647) NOT NULL, 
        managerrole int4, 
        name text(2147483647) NOT NULL, 
        showinsale bool DEFAULT TRUE NOT NULL, 
        converted_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT masterprodgrp_to_emprole_fk FOREIGN KEY (managerrole) REFERENCES "exerp"."roles" 
        ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
