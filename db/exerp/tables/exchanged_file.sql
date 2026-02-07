CREATE TABLE 
    exchanged_file 
    ( 
        id int4 NOT NULL, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        service text(2147483647) NOT NULL, 
        agency int4, 
        entry_time int8 NOT NULL, 
        timeout_time int8, 
        employee_center int4, 
        employee_id int4, 
        store_in_database bool DEFAULT TRUE NOT NULL, 
        store_in_filesystem bool DEFAULT FALSE NOT NULL, 
        filesystem_location text(2147483647), 
        filename            text(2147483647), 
        mime_type           text(2147483647), 
        mime_value bytea, 
        zipped bool NOT NULL, 
        filehash text(2147483647), 
        coment   text(2147483647), 
        configuration bytea, 
        mod               text(2147483647) NOT NULL, 
        status            text(2147483647) NOT NULL, 
        current_operation text(2147483647), 
        records int4, 
        amount NUMERIC(0,0), 
        errors int4, 
        exported bool DEFAULT FALSE NOT NULL, 
        file_format text(2147483647), 
        earliest_time int8, 
        schedule_id int4, 
        reference_file_id int4, 
        retry_timeout int8, 
        handling_type text(2147483647), 
        export_as_gzip bool, 
        entity_reference_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT ef_employee_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT fk_ex_sched FOREIGN KEY (schedule_id) REFERENCES "exerp"."exchanged_file_sc" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
