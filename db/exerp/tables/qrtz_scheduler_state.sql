CREATE TABLE 
    qrtz_scheduler_state 
    ( 
        instance_name VARCHAR(200) NOT NULL, 
        last_checkin_time float8(17,17) NOT NULL, 
        checkin_interval float8(17,17) NOT NULL, 
        PRIMARY KEY (instance_name) 
    );
