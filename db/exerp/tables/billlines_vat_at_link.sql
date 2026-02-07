CREATE TABLE 
    billlines_vat_at_link 
    ( 
        id int4 DEFAULT 0 NOT NULL, 
        billline_center int4 NOT NULL, 
        billline_id int4 NOT NULL, 
        billline_subid int4 NOT NULL, 
        account_trans_center int4 NOT NULL, 
        account_trans_id int4 NOT NULL, 
        account_trans_subid int4 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT blvatl_at_fk FOREIGN KEY (account_trans_center, account_trans_id, 
        account_trans_subid) REFERENCES "exerp"."account_trans" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT blvatl_bl_fk FOREIGN KEY (billline_center, billline_id, billline_subid) REFERENCES 
    "exerp"."bill_lines_mt" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
