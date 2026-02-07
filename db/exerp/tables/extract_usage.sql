CREATE TABLE 
    extract_usage 
    ( 
        id int4 NOT NULL, 
        extract_id int4 NOT NULL, 
        TIME int8 NOT NULL, 
        employee_center int4, 
        employee_id int4, 
        rows_returned int4 NOT NULL, 
        time_used int8 NOT NULL, 
        source text(2147483647) NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT eu_to_employee_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT eu_to_extract_fk FOREIGN KEY (extract_id) REFERENCES "exerp"."extract" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
