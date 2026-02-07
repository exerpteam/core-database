CREATE TABLE 
    employee_login_attempts 
    ( 
        employee_center int4 NOT NULL, 
        employee_id int4 NOT NULL, 
        client_instance int4 NOT NULL, 
        entry_time int8 NOT NULL, 
        success bool NOT NULL, 
        ignore bool NOT NULL 
    );
