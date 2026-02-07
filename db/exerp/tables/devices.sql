CREATE TABLE 
    devices 
    ( 
        id int4 NOT NULL, 
        client int4, 
        name   text(2147483647) NOT NULL, 
        driver text(2147483647) NOT NULL, 
        enabled bool NOT NULL, 
        configuration bytea, 
        uninstall_driver bool, 
        PRIMARY KEY (id), 
        CONSTRAINT device_to_client_fk FOREIGN KEY (client) REFERENCES "exerp"."clients" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
