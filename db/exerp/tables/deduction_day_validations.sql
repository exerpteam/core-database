CREATE TABLE 
    deduction_day_validations 
    ( 
        id int4 NOT NULL, 
        payment_cycle_config_id int4 NOT NULL, 
        plugin_id text(2147483647) NOT NULL, 
        plugin_config bytea NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT ddvplugin_to_pcc_fk FOREIGN KEY (payment_cycle_config_id) REFERENCES 
        "exerp"."payment_cycle_config" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
