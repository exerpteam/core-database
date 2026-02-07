CREATE TABLE 
    supplier 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        active bool NOT NULL, 
        external_id       text(2147483647) NOT NULL, 
        supply_scope_type text(2147483647) NOT NULL, 
        supply_scope_id int4 NOT NULL, 
        delivery_time            text(2147483647) NOT NULL, 
        finance_account_globalid text(2147483647) NOT NULL, 
        PRIMARY KEY (center, id), 
        CONSTRAINT supplier_to_company_fk FOREIGN KEY (center, id) REFERENCES "exerp"."persons" 
        ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
