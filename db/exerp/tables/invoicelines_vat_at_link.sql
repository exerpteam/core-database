CREATE TABLE 
    invoicelines_vat_at_link 
    ( 
        id int4 NOT NULL, 
        invoiceline_center int4 NOT NULL, 
        invoiceline_id int4 NOT NULL, 
        invoiceline_subid int4 NOT NULL, 
        account_trans_center int4 NOT NULL, 
        account_trans_id int4 NOT NULL, 
        account_trans_subid int4 NOT NULL, 
        rate      NUMERIC(0,0) NOT NULL, 
        orig_rate NUMERIC(0,0) NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT ilvatl_at_fk FOREIGN KEY (account_trans_center, account_trans_id, 
        account_trans_subid) REFERENCES "exerp"."account_trans" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ilvatl_il_fk FOREIGN KEY (invoiceline_center, invoiceline_id, invoiceline_subid) 
    REFERENCES "exerp"."invoice_lines_mt" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
