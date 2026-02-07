CREATE TABLE 
    account_vat_type_link 
    ( 
        id int4 NOT NULL, 
        vat_type_center int4 NOT NULL, 
        vat_type_id int4 NOT NULL, 
        account_vat_type_group_id int4 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT avtl_to_avtg_fk FOREIGN KEY (account_vat_type_group_id) REFERENCES 
        "exerp"."account_vat_type_group" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT avtl_to_vt_fk FOREIGN KEY (vat_type_center, vat_type_id) REFERENCES 
    "exerp"."vat_types" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
