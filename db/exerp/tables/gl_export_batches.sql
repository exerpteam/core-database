CREATE TABLE 
    gl_export_batches 
    ( 
        id int4 NOT NULL, 
        entry_time int8 NOT NULL, 
        exchanged_file_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT gl_exp_batch_to_exch_file_fk FOREIGN KEY (exchanged_file_id) REFERENCES 
        "exerp"."exchanged_file" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
