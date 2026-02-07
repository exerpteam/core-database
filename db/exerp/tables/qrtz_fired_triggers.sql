CREATE TABLE 
    qrtz_fired_triggers 
    ( 
        entry_id      VARCHAR(95) NOT NULL, 
        trigger_name  text(2147483647) NOT NULL, 
        trigger_group text(2147483647) NOT NULL, 
        is_volatile bool NOT NULL, 
        instance_name text(2147483647) NOT NULL, 
        fired_time float8(17,17) NOT NULL, 
        priority float8(17,17) NOT NULL, 
        STATE     text(2147483647) NOT NULL, 
        job_name  text(2147483647), 
        job_group text(2147483647), 
        is_stateful bool, 
        requests_recovery bool, 
        PRIMARY KEY (entry_id) 
    );
