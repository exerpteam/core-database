CREATE TABLE 
    bill_lines_mt 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        account_trans_center int4 NOT NULL, 
        account_trans_id int4 NOT NULL, 
        account_trans_subid int4 NOT NULL, 
              text bytea, 
        text2 text(2147483647), 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT billline_to_acctrans_fk FOREIGN KEY (account_trans_center, account_trans_id, 
        account_trans_subid) REFERENCES "exerp"."account_trans" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT billline_to_bill_fk FOREIGN KEY (center, id) REFERENCES "exerp"."bills" ("center", 
    "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
