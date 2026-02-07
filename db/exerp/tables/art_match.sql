CREATE TABLE 
    art_match 
    ( 
        id int4 NOT NULL, 
        art_paying_center int4 NOT NULL, 
        art_paying_id int4 NOT NULL, 
        art_paying_subid int4 NOT NULL, 
        art_paid_center int4 NOT NULL, 
        art_paid_id int4 NOT NULL, 
        art_paid_subid int4 NOT NULL, 
        amount NUMERIC(0,0) NOT NULL, 
        entry_time int8 NOT NULL, 
        cancelled_time int8, 
        used_rule int4 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT art_match_to_payee_fk FOREIGN KEY (art_paid_center, art_paid_id, art_paid_subid) 
        REFERENCES "exerp"."ar_trans" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT art_match_to_payer_fk FOREIGN KEY (art_paying_center, art_paying_id, 
    art_paying_subid) REFERENCES "exerp"."ar_trans" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
