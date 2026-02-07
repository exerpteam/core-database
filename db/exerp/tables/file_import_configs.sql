CREATE TABLE 
    file_import_configs 
    ( 
        id int4 NOT NULL, 
        scope_type VARCHAR(1) NOT NULL, 
        scope_id int4 NOT NULL, 
        name    VARCHAR(50) NOT NULL, 
        service VARCHAR(50) NOT NULL, 
        agency int4 NOT NULL, 
        target_id int4 NOT NULL, 
        source           VARCHAR(100), 
        filename_pattern VARCHAR(100), 
        description      VARCHAR(2000), 
        status           VARCHAR(20) NOT NULL, 
        quick_file_process bool DEFAULT FALSE NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT fic_to_sftp_fk FOREIGN KEY (target_id) REFERENCES "exerp"."sftp_targets" ("id") 
        ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
