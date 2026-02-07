CREATE TABLE 
    log_in_log 
    ( 
        id int4 NOT NULL, 
        employee_center int4 NOT NULL, 
        employee_id int4 NOT NULL, 
        log_in_time int8 NOT NULL, 
        log_out_time int8, 
        client_instance_id int4 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT log_in_log_to_client_inst_fk FOREIGN KEY (client_instance_id) REFERENCES 
        "exerp"."client_instances" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
