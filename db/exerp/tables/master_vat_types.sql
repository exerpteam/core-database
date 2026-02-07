CREATE TABLE 
    master_vat_types 
    ( 
        id int4 NOT NULL, 
        name       text(2147483647) NOT NULL, 
        globalid   text(2147483647) NOT NULL, 
        scope_type text(2147483647), 
        scope_id int4, 
        master_account text(2147483647) NOT NULL, 
        rate           NUMERIC(0,0) NOT NULL, 
        orig_rate      NUMERIC(0,0) NOT NULL, 
        external_id    text(2147483647), 
        definition bool DEFAULT TRUE NOT NULL, 
        available bool DEFAULT TRUE NOT NULL, 
        PRIMARY KEY (id) 
    );
