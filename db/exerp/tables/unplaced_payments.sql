CREATE TABLE 
    unplaced_payments 
    ( 
        id int4 NOT NULL, 
        STATE int4 NOT NULL, 
        xfr_delivery int4, 
        xfr_rec_no int4, 
        xfr_date        DATE NOT NULL, 
        xfr_amount      NUMERIC(0,0) NOT NULL, 
        xfr_info        text(2147483647), 
        xfr_text        text(2147483647), 
        xfr_debitor_id  text(2147483647), 
        xfr_creditor_id text(2147483647), 
        account_center int4, 
        account_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT unplac_paym_to_clear_in_fk FOREIGN KEY (xfr_delivery) REFERENCES 
        "exerp"."clearing_in" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
