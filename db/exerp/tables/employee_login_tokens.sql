CREATE TABLE 
    employee_login_tokens 
    ( 
        id int4 NOT NULL, 
        employee_center int4 NOT NULL, 
        employee_id int4 NOT NULL, 
        created_at int8 NOT NULL, 
        token text(2147483647) NOT NULL, 
        version int8, 
        last_used int8, 
        PRIMARY KEY (id), 
        CONSTRAINT fk_elt_created_to_employee FOREIGN KEY (employee_center, employee_id) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
