CREATE TABLE 
    vending_machine 
    ( 
        id int4 NOT NULL, 
        center int4 NOT NULL, 
        name text(2147483647) NOT NULL, 
        cash_register_center int4 NOT NULL, 
        cash_register_id int4 NOT NULL, 
        STATE       text(2147483647) NOT NULL, 
        external_id text(2147483647), 
        reverse_id_rfcard bool DEFAULT FALSE NOT NULL, 
        dec_to_hex_id_rfcard bool DEFAULT FALSE NOT NULL, 
        operator_id text(2147483647), 
        PRIMARY KEY (id), 
        CONSTRAINT vending_machine_to_cash_reg_fk FOREIGN KEY (cash_register_center, 
        cash_register_id) REFERENCES "exerp"."cashregisters" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT vending_machine_to_center_fk FOREIGN KEY (center) REFERENCES "exerp"."centers" ("id" 
    ) 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
