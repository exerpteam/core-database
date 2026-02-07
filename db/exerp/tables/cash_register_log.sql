CREATE TABLE 
    cash_register_log 
    ( 
        id int4 NOT NULL, 
        cash_register_center int4 NOT NULL, 
        cash_register_id int4 NOT NULL, 
        log_type            text(2147483647) NOT NULL, 
        reference_global_id text(2147483647), 
        reference_center int4, 
        reference_id int4, 
        reference_sub_id int4, 
        log_time int8 NOT NULL, 
        event_time int8, 
        employee_center int4, 
        employee_id int4, 
        receipt bytea, 
        PRIMARY KEY (id), 
        CONSTRAINT cash_reg_log_to_cash_reg_fk FOREIGN KEY (cash_register_center, cash_register_id) 
        REFERENCES "exerp"."cashregisters" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
