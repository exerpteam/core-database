CREATE TABLE 
    person_change_logs 
    ( 
        id int4 NOT NULL, 
        person_center int4 NOT NULL, 
        person_id int4 NOT NULL, 
        previous_entry_id int4, 
        change_source    text(2147483647) NOT NULL, 
        change_attribute text(2147483647) NOT NULL, 
        new_value        text(2147483647), 
        entry_time int8 NOT NULL, 
        employee_center int4, 
        employee_id int4, 
        login_type text(2147483647) NOT NULL, 
        PRIMARY KEY (id) 
    );
