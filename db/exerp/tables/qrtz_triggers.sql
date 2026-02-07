CREATE TABLE 
    qrtz_triggers 
    ( 
        trigger_name  VARCHAR(200) NOT NULL, 
        trigger_group VARCHAR(200) NOT NULL, 
        job_name      text(2147483647) NOT NULL, 
        job_group     text(2147483647) NOT NULL, 
        is_volatile bool NOT NULL, 
        description text(2147483647), 
        next_fire_time float8(17,17), 
        prev_fire_time float8(17,17), 
        priority float8(17,17), 
        trigger_state text(2147483647) NOT NULL, 
        trigger_type  text(2147483647) NOT NULL, 
        start_time float8(17,17) NOT NULL, 
        end_time float8(17,17), 
        calendar_name text(2147483647), 
        misfire_instr float4(8,8), 
        job_data bytea, 
        PRIMARY KEY (trigger_name, trigger_group), 
        CONSTRAINT qrtz_triggers_job_name_fkey FOREIGN KEY (job_name, job_group) REFERENCES 
        "exerp"."qrtz_job_details" ("job_name", "job_group") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
