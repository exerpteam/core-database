CREATE TABLE 
    licenses 
    ( 
        id int4 NOT NULL, 
        center_id int4 NOT NULL, 
        feature    text(2147483647) NOT NULL, 
        start_date DATE NOT NULL, 
        stop_date  DATE, 
        contract_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT license_to_center_fk FOREIGN KEY (center_id) REFERENCES "exerp"."centers" ("id") 
        ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT license_to_contract_fk FOREIGN KEY (contract_id) REFERENCES "exerp"."contracts" 
    ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
