CREATE TABLE 
    credit_note_line_vat_at_link 
    ( 
        id int4 NOT NULL, 
        credit_note_line_center int4 NOT NULL, 
        credit_note_line_id int4 NOT NULL, 
        credit_note_line_subid int4 NOT NULL, 
        account_trans_center int4 NOT NULL, 
        account_trans_id int4 NOT NULL, 
        account_trans_subid int4 NOT NULL, 
        rate      NUMERIC(0,0) NOT NULL, 
        orig_rate NUMERIC(0,0) NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT cnlvatl_at_fk FOREIGN KEY (account_trans_center, account_trans_id, 
        account_trans_subid) REFERENCES "exerp"."account_trans" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cnlvatl_cnl_fk FOREIGN KEY (credit_note_line_center, credit_note_line_id, 
    credit_note_line_subid) REFERENCES "exerp"."credit_note_lines_mt" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
