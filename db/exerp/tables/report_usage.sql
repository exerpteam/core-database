CREATE TABLE 
    report_usage 
    ( 
        id int4 NOT NULL, 
        report_key text(2147483647) NOT NULL, 
                   TIME int8 NOT NULL, 
        employee_center int4 NOT NULL, 
        employee_id int4 NOT NULL, 
        rows_returned int4 NOT NULL, 
        time_used int8 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT ru_to_employee_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
