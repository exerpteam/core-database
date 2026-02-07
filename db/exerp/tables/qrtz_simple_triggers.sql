CREATE TABLE 
    qrtz_simple_triggers 
    ( 
        trigger_name  VARCHAR(200) NOT NULL, 
        trigger_group VARCHAR(200) NOT NULL, 
        repeat_count float8(17,17) NOT NULL, 
        repeat_interval float8(17,17) NOT NULL, 
        times_triggered float8(17,17) NOT NULL, 
        PRIMARY KEY (trigger_name, trigger_group), 
        CONSTRAINT qrtz_simple_triggers_trigger_name_fkey FOREIGN KEY (trigger_name, trigger_group) 
        REFERENCES "exerp"."qrtz_triggers" ("trigger_name", "trigger_group") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
