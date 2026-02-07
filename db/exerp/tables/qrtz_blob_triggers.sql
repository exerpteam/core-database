CREATE TABLE 
    qrtz_blob_triggers 
    ( 
        trigger_name  VARCHAR(200) NOT NULL, 
        trigger_group VARCHAR(200) NOT NULL, 
        blob_data bytea, 
        PRIMARY KEY (trigger_name, trigger_group), 
        CONSTRAINT qrtz_blob_triggers_trigger_name_fkey FOREIGN KEY (trigger_name, trigger_group) 
        REFERENCES "exerp"."qrtz_triggers" ("trigger_name", "trigger_group") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
