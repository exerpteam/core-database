CREATE TABLE 
    gates 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        name text(2147483647) NOT NULL, 
        device_id int4, 
        device_sub_id text(2147483647), 
        PRIMARY KEY (center, id), 
        CONSTRAINT ga_to_device_fk FOREIGN KEY (device_id) REFERENCES "exerp"."devices" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
