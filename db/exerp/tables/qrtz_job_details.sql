CREATE TABLE 
    qrtz_job_details 
    ( 
        job_name       VARCHAR(200) NOT NULL, 
        job_group      VARCHAR(200) NOT NULL, 
        description    text(2147483647), 
        job_class_name text(2147483647) NOT NULL, 
        is_durable bool NOT NULL, 
        is_volatile bool NOT NULL, 
        is_stateful bool NOT NULL, 
        requests_recovery bool NOT NULL, 
        job_data bytea, 
        PRIMARY KEY (job_name, job_group) 
    );
