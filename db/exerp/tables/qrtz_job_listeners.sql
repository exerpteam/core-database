CREATE TABLE 
    qrtz_job_listeners 
    ( 
        job_name     VARCHAR(200) NOT NULL, 
        job_group    VARCHAR(200) NOT NULL, 
        job_listener VARCHAR(200) NOT NULL, 
        PRIMARY KEY (job_name, job_group, job_listener), 
        CONSTRAINT qrtz_job_listeners_job_name_fkey FOREIGN KEY (job_name, job_group) REFERENCES 
        "exerp"."qrtz_job_details" ("job_name", "job_group") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
