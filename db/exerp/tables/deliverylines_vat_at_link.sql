CREATE TABLE 
    deliverylines_vat_at_link 
    ( 
        id int4 DEFAULT 0 NOT NULL, 
        deliveryline_center int4 NOT NULL, 
        deliveryline_id int4 NOT NULL, 
        deliveryline_subid int4 NOT NULL, 
        vat_amount NUMERIC(0,0), 
        account_trans_center int4 NOT NULL, 
        account_trans_id int4 NOT NULL, 
        account_trans_subid int4 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT dlvatl_at_fk FOREIGN KEY (account_trans_center, account_trans_id, 
        account_trans_subid) REFERENCES "exerp"."account_trans" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT dlvatl_dl_fk FOREIGN KEY (deliveryline_center, deliveryline_id, deliveryline_subid) 
    REFERENCES "exerp"."delivery_lines_mt" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
