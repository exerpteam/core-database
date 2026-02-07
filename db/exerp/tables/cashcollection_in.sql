CREATE TABLE 
    cashcollection_in 
    ( 
        id int4 NOT NULL, 
        cashcollectionservice int4, 
        STATE int4 NOT NULL, 
        REF            text(2147483647), 
        received_date  DATE NOT NULL, 
        generated_date DATE, 
        delivery bytea, 
        errors bytea, 
        filename     text(2147483647), 
        total_amount NUMERIC(0,0), 
        payment_count int4, 
        PRIMARY KEY (id), 
        CONSTRAINT ccin_to_ccservice_fk FOREIGN KEY (cashcollectionservice) REFERENCES 
        "exerp"."cashcollectionservices" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
