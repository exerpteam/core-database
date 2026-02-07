CREATE TABLE 
    license_change_logs 
    ( 
        id int4 NOT NULL, 
        employee_center int4, 
        employee_id int4, 
        date_time int8 NOT NULL, 
        description text(2147483647) NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT lcl_to_employee_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
