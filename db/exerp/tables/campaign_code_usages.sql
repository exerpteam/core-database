CREATE TABLE 
    campaign_code_usages 
    ( 
        id int4 NOT NULL, 
        campaign_code_id int4 NOT NULL, 
        external_id text(2147483647), 
        usage_count int4 DEFAULT 0 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT ccu_to_cc_id FOREIGN KEY (campaign_code_id) REFERENCES "exerp"."campaign_codes" 
        ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
