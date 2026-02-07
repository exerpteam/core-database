CREATE TABLE 
    privilege_usages 
    ( 
        id int4 NOT NULL, 
        STATE        text(2147483647) NOT NULL, 
        misuse_state text(2147483647) NOT NULL, 
        grant_id int4, 
        privilege_id int4 NOT NULL, 
        privilege_type  text(2147483647) NOT NULL, 
        source_globalid text(2147483647), 
        source_center int4, 
        source_id int4, 
        source_subid int4, 
        target_service  text(2147483647) NOT NULL, 
        target_globalid text(2147483647), 
        target_center int4, 
        target_id int4, 
        target_subid int4, 
        target_start_time int8, 
        deduction_quantity int4, 
        deduction_key text(2147483647), 
        deduction_usage int4, 
        deduction_time text(2147483647), 
        plan_time int8 NOT NULL, 
        use_time int8, 
        cancel_time int8, 
        punishment_key text(2147483647), 
        campaign_code_id int4, 
        COUNT int4, 
        person_center int4, 
        person_id int4, 
        last_modified int8, 
        PRIMARY KEY (id), 
        CONSTRAINT priv_usage_to_campaign_code FOREIGN KEY (campaign_code_id) REFERENCES 
        "exerp"."campaign_codes" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT priv_usage_to_priv_grant FOREIGN KEY (grant_id) REFERENCES 
    "exerp"."privilege_grants" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT priv_usage_to_deduction_usage FOREIGN KEY (deduction_usage) REFERENCES 
    "exerp"."privilege_usages" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
