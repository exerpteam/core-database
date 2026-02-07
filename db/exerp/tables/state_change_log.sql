CREATE TABLE 
    state_change_log 
    ( 
        KEY int4 NOT NULL, 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4, 
        entry_type int4 NOT NULL, 
        stateid int4 NOT NULL, 
        sub_state int4, 
        entry_start_time int8 NOT NULL, 
        entry_end_time int8, 
        book_start_time int8 NOT NULL, 
        book_end_time int8, 
        had_report_role bool NOT NULL, 
        employee_center int4, 
        employee_id int4, 
        PRIMARY KEY (KEY), 
        CONSTRAINT stl_to_employees_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
