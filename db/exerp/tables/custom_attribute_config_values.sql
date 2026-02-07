CREATE TABLE 
    custom_attribute_config_values 
    ( 
        id int4 NOT NULL, 
        external_id VARCHAR(100) NOT NULL, 
        VALUE       VARCHAR(4000) NOT NULL, 
        custom_attribute_config_id int4 NOT NULL, 
        rank int4 NOT NULL, 
        STATE VARCHAR(15) DEFAULT 'ACTIVE'::character VARYING NOT NULL, 
        last_modified int8, 
        PRIMARY KEY (id), 
        CONSTRAINT cae_to_config FOREIGN KEY (custom_attribute_config_id) REFERENCES 
        "exerp"."custom_attribute_configs" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
