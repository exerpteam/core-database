CREATE TABLE 
    error_reports 
    ( 
        id int4 NOT NULL, 
        client_instance int4 NOT NULL, 
        exceptionid text(2147483647), 
        reporter_center int4 NOT NULL, 
        reporter_id int4 NOT NULL, 
        created_on int8 NOT NULL, 
        external_id text(2147483647), 
        issue_tracker_exported_on int8, 
        stacktrace bytea, 
        log bytea, 
        model_fields bytea, 
        ui_events bytea, 
        enviroment_info bytea, 
        clublead_central_info bytea, 
        screenshot_type text(2147483647), 
        screenshot_value bytea, 
        deleted bool NOT NULL, 
        title       text(2147483647), 
        description text(2147483647), 
        automatic_generated bool, 
        issue_tracker_id VARCHAR(12), 
        PRIMARY KEY (id), 
        CONSTRAINT error_rep_to_client_inst_fk FOREIGN KEY (client_instance) REFERENCES 
        "exerp"."client_instances" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
