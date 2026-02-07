CREATE TABLE 
    payment_accounts 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        active_agr_center int4, 
        active_agr_id int4, 
        active_agr_subid int4, 
        day_in_interval int4, 
        PRIMARY KEY (center, id), 
        CONSTRAINT payacc_to_ar_fk FOREIGN KEY (center, id) REFERENCES 
        "exerp"."account_receivables" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT payment_acc_to_agreement_fk FOREIGN KEY (active_agr_center, active_agr_id, 
    active_agr_subid) REFERENCES "exerp"."payment_agreements" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
