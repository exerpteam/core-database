CREATE TABLE 
    cashcollection_out 
    ( 
        id int4 NOT NULL, 
        cashcollectionservice int4, 
        STATE int4 NOT NULL, 
        REF            text(2147483647) NOT NULL, 
        generated_date DATE NOT NULL, 
        sent_date      DATE, 
        amount_req     NUMERIC(0,0) NOT NULL, 
        nb_req int4 NOT NULL, 
        delivery bytea, 
        PRIMARY KEY (id), 
        CONSTRAINT ccout_to_ccservice_fk FOREIGN KEY (cashcollectionservice) REFERENCES 
        "exerp"."cashcollectionservices" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
