CREATE TABLE 
    ch_and_pcc_link 
    ( 
        clearing_house_id int4 NOT NULL, 
        payment_cycle_id int4 NOT NULL, 
        PRIMARY KEY (clearing_house_id, payment_cycle_id), 
        CONSTRAINT ch_and_pcc_to_ch_fk FOREIGN KEY (clearing_house_id) REFERENCES 
        "exerp"."clearinghouses" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ch_and_pcc_to_pc_fk FOREIGN KEY (payment_cycle_id) REFERENCES 
    "exerp"."payment_cycle_config" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
