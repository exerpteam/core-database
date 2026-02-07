CREATE TABLE 
    awsdms_history 
    ( 
        server_name   VARCHAR(128) NOT NULL, 
        task_name     VARCHAR(128) NOT NULL, 
        timeslot_type VARCHAR(32) NOT NULL, 
        timeslot      TIMESTAMP NOT NULL, 
        timeslot_duration int8, 
        timeslot_latency int8, 
        timeslot_records int8, 
        timeslot_volume int8 
    );
