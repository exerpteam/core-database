CREATE TABLE 
    clearing_in 
    ( 
        id int4 NOT NULL, 
        clearinghouse int4, 
        STATE int4 NOT NULL, 
        REF text(2147483647), 
        payment_count int4, 
        total_amount   NUMERIC(0,0), 
        received_date  DATE NOT NULL, 
        generated_date DATE, 
        delivery bytea, 
        errors bytea, 
        substate int4, 
        filename text(2147483647), 
        checksum text(2147483647), 
        exchanged_file_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT clearin_to_clearhouse_fk FOREIGN KEY (clearinghouse) REFERENCES 
        "exerp"."clearinghouses" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT clearin_to_exchangefile_fk FOREIGN KEY (exchanged_file_id) REFERENCES 
    "exerp"."exchanged_file" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
