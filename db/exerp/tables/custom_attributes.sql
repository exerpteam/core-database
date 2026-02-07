CREATE TABLE 
    custom_attributes 
    ( 
        id int4 NOT NULL, 
        custom_attribute_config_value_id int4, 
        ref_type VARCHAR(15) NOT NULL, 
        ref_id int4 NOT NULL, 
        ref_center_id int4, 
        STATE VARCHAR(15) DEFAULT 'ACTIVE'::character VARYING NOT NULL, 
        last_modified int8, 
        text_value VARCHAR(4000), 
        custom_attribute_config_id int4 DEFAULT 0 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT cae_to_entry FOREIGN KEY (custom_attribute_config_value_id) REFERENCES 
        "exerp"."custom_attribute_config_values" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ca_to_config FOREIGN KEY (custom_attribute_config_id) REFERENCES 
    "exerp"."custom_attribute_configs" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
