CREATE TABLE 
    task_log_details 
    ( 
        id int4 NOT NULL, 
        task_log_id int4, 
        type text(2147483647) NOT NULL, 
        reference_center int4, 
        reference_id int4, 
        reference_sub_id int4, 
        reference_table text(2147483647), 
        name            text(2147483647), 
        VALUE           text(2147483647), 
        PRIMARY KEY (id), 
        CONSTRAINT tsklgdetails_to_tsklg_fk FOREIGN KEY (task_log_id) REFERENCES "exerp"."task_log" 
        ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
