CREATE TABLE 
    exchanged_file_op 
    ( 
        id int4 NOT NULL, 
        exchanged_file_id int4, 
        start_time int8 NOT NULL, 
        stop_time int8 NOT NULL, 
        employee_center int4, 
        employee_id int4, 
        operation_id text(2147483647), 
        RESULT       text(2147483647) NOT NULL, 
        records int4, 
        amount NUMERIC(0,0), 
        errors int4, 
        error_retry bool DEFAULT FALSE NOT NULL, 
        error_log bytea, 
        PRIMARY KEY (id), 
        CONSTRAINT efo_employee_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT efo_ef_fk FOREIGN KEY (exchanged_file_id) REFERENCES "exerp"."exchanged_file" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
