CREATE TABLE 
    bills 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        employee_center int4 NOT NULL, 
        employee_id int4 NOT NULL, 
        bill_no text(2147483647), 
        trans_time int8 NOT NULL, 
                     text bytea, 
        text2        text(2147483647), 
        total_amount NUMERIC(0,0) NOT NULL, 
        PRIMARY KEY (center, id), 
        CONSTRAINT bill_to_employee_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
