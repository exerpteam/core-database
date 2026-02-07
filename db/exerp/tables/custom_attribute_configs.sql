CREATE TABLE 
    custom_attribute_configs 
    ( 
        id int4 NOT NULL, 
        name        VARCHAR(100) NOT NULL, 
        external_id VARCHAR(60) NOT NULL, 
        rank int4 NOT NULL, 
        ref_type VARCHAR(30) DEFAULT 'NULL::character varying' NOT NULL, 
        ref_id int4 NOT NULL, 
        STATE VARCHAR(15) DEFAULT 'ACTIVE'::character VARYING NOT NULL, 
        last_modified int8, 
        type VARCHAR(30) DEFAULT 'SINGLE_SELECTION'::character VARYING NOT NULL, 
        PRIMARY KEY (id) 
    );
