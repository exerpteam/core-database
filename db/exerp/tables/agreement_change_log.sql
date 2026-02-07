CREATE TABLE 
    agreement_change_log 
    ( 
        id int4 NOT NULL, 
        log_date DATE NOT NULL, 
        agreement_center int4, 
        agreement_id int4, 
        agreement_subid int4, 
        STATE int4 NOT NULL, 
             text text(2147483647), 
        code text(2147483647), 
        entry_time int8 DEFAULT 0 NOT NULL, 
        clearing_in int4, 
        employee_center int4, 
        employee_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT agr_change_agr_fg FOREIGN KEY (agreement_center, agreement_id, agreement_subid) 
        REFERENCES "exerp"."payment_agreements" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
