CREATE TABLE 
    qrtz_cron_triggers 
    ( 
        trigger_name    VARCHAR(200) NOT NULL, 
        trigger_group   VARCHAR(200) NOT NULL, 
        cron_expression text(2147483647) NOT NULL, 
        time_zone_id    text(2147483647), 
        PRIMARY KEY (trigger_name, trigger_group), 
        CONSTRAINT qrtz_cron_triggers_trigger_name_fkey FOREIGN KEY (trigger_name, trigger_group) 
        REFERENCES "exerp"."qrtz_triggers" ("trigger_name", "trigger_group") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
