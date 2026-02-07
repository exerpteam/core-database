CREATE TABLE 
    account_vat_type_group 
    ( 
        id int4 NOT NULL, 
        account_center int4 NOT NULL, 
        account_id int4 NOT NULL, 
        global_id text(2147483647), 
        PRIMARY KEY (id), 
        CONSTRAINT avtg_to_ac_fk FOREIGN KEY (account_center, account_id) REFERENCES 
        "exerp"."accounts" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
