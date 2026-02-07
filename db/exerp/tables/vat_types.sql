CREATE TABLE 
    vat_types 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        name     text(2147483647) NOT NULL, 
        globalid text(2147483647), 
        accountcenter int4, 
        accountid int4, 
        rate        NUMERIC(0,0) NOT NULL, 
        orig_rate   NUMERIC(0,0) NOT NULL, 
        external_id text(2147483647), 
        PRIMARY KEY (center, id), 
        CONSTRAINT vattype_to_vatacc_fk FOREIGN KEY (accountcenter, accountid) REFERENCES 
        "exerp"."accounts" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
