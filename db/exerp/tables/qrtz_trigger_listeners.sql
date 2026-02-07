CREATE TABLE 
    qrtz_trigger_listeners 
    ( 
        trigger_name     VARCHAR(200) NOT NULL, 
        trigger_group    VARCHAR(200) NOT NULL, 
        trigger_listener VARCHAR(200) NOT NULL, 
        PRIMARY KEY (trigger_name, trigger_group, trigger_listener), 
        CONSTRAINT qrtz_trigger_listeners_trigger_name_fkey FOREIGN KEY (trigger_name, 
        trigger_group) REFERENCES "exerp"."qrtz_triggers" ("trigger_name", "trigger_group") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
