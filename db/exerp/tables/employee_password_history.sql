CREATE TABLE 
    employee_password_history 
    ( 
        id int4 NOT NULL, 
        start_date DATE NOT NULL, 
        end_date   DATE, 
        log_date int8 NOT NULL, 
        employee_center int4, 
        employee_id int4, 
        password      VARCHAR(32) DEFAULT 'NULL::character varying', 
        password_hash VARCHAR(65), 
        password_hash_method int4 DEFAULT 1, 
        PRIMARY KEY (id), 
        CONSTRAINT pahi_to_employee_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
