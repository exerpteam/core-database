CREATE TABLE 
    awsdms_suspended_tables 
    ( 
        server_name       VARCHAR(128) NOT NULL, 
        task_name         VARCHAR(128) NOT NULL, 
        table_owner       VARCHAR(128) NOT NULL, 
        table_name        VARCHAR(128) NOT NULL, 
        suspend_reason    VARCHAR(32), 
        suspend_timestamp TIMESTAMP 
    );
