CREATE TABLE 
    aggregated_transactions 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        entry_time int8 NOT NULL, 
        book_date                      DATE NOT NULL, 
        amount                         NUMERIC(0,0), 
        debit_account_external_id      text(2147483647), 
        credit_account_external_id     text(2147483647), 
        vat_amount                     NUMERIC(0,0), 
        debit_vat_account_external_id  text(2147483647), 
        credit_vat_account_external_id text(2147483647), 
        vat_rate                       NUMERIC(0,0), 
        vat_external_id                text(2147483647), 
                                       text text(2147483647), 
        info_type int4 NOT NULL, 
        info text(2147483647) NOT NULL, 
        gl_export_batch_id int4, 
        PRIMARY KEY (center, id), 
        CONSTRAINT aggregated_trans_to_center_fk FOREIGN KEY (center) REFERENCES "exerp"."centers" 
        ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT agg_trans_to_gl_exp_batch_fk FOREIGN KEY (gl_export_batch_id) REFERENCES 
    "exerp"."gl_export_batches" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
