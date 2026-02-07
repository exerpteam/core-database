CREATE TABLE 
    center_change_logs 
    ( 
        id int4 NOT NULL, 
        center_id int4 NOT NULL, 
        previous_entry_id int4, 
        change_source    text(2147483647) NOT NULL, 
        change_attribute text(2147483647) NOT NULL, 
        new_value        text(2147483647), 
        entry_time int8 NOT NULL, 
        employee_center int4, 
        employee_id int4, 
        login_type text(2147483647) NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT center_change_log_to_center_fk FOREIGN KEY (center_id) REFERENCES 
        "exerp"."centers" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
