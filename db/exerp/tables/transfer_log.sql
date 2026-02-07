CREATE TABLE 
    transfer_log 
    ( 
        id int4 NOT NULL, 
        entity_id int4 NOT NULL, 
        entry_start_time int8 NOT NULL, 
        entry_end_time int8, 
        center int4 NOT NULL, 
        employee_center int4, 
        employee_id int4, 
        PRIMARY KEY (id) 
    );
