CREATE TABLE 
    clearing_out 
    ( 
        id int4 NOT NULL, 
        clearinghouse int4, 
        STATE int4 NOT NULL, 
        REF            text(2147483647) NOT NULL, 
        generated_date DATE NOT NULL, 
        sent_date      DATE, 
        confirmed_date DATE, 
        total_amount   NUMERIC(0,0), 
        invoice_count int4, 
        total_reversal_amount NUMERIC(0,0), 
        reversal_count int4, 
        delivery bytea, 
        errors bytea, 
        requested_date                DATE, 
        handler_type                  text(2147483647) DEFAULT 'FILE'::text NOT NULL, 
        file_name_provided_by_handler text(2147483647) DEFAULT 'null'::text, 
        exchanged_file int4, 
        PRIMARY KEY (id), 
        CONSTRAINT clearout_to_clearhouse_fk FOREIGN KEY (clearinghouse) REFERENCES 
        "exerp"."clearinghouses" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT clearout_to_exchangefile_fk FOREIGN KEY (exchanged_file) REFERENCES 
    "exerp"."exchanged_file" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
