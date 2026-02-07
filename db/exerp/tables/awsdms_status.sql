CREATE TABLE 
    awsdms_status 
    ( 
        server_name VARCHAR(128) NOT NULL, 
        task_name   VARCHAR(128) NOT NULL, 
        task_status VARCHAR(32), 
        status_time TIMESTAMP, 
        pending_changes int8, 
        disk_swap_size int8, 
        task_memory int8, 
        source_current_position  VARCHAR(128), 
        source_current_timestamp TIMESTAMP, 
        source_tail_position     VARCHAR(128), 
        source_tail_timestamp    TIMESTAMP, 
        source_timestamp_applied TIMESTAMP 
    );
