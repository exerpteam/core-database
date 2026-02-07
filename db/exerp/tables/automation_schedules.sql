CREATE TABLE 
    automation_schedules 
    ( 
        id int4 NOT NULL, 
        entry_time    TIMESTAMP NOT NULL, 
        schedule_type VARCHAR(30) NOT NULL, 
        schedule_configuration bytea, 
        status          VARCHAR(25) NOT NULL, 
        automation_type VARCHAR(30) NOT NULL, 
        automation_key int4 NOT NULL, 
        next_time_to_run TIMESTAMP, 
        PRIMARY KEY (id) 
    );
