CREATE TABLE 
    subscription_retention_campaigns 
    ( 
        id serial DEFAULT nextval('subscription_retention_campaigns_id_seq'::regclass) NOT NULL, 
        subscription_center int4 NOT NULL, 
        subscription_id int4 NOT NULL, 
        campaign_id int4 NOT NULL, 
        privilege_start_date DATE NOT NULL, 
        campaign_code_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT subscription_retention_campaign_to_campaign_codes_fk FOREIGN KEY 
        (campaign_code_id) REFERENCES "exerp"."campaign_codes" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT subscription_retention_campaign_to_campaigns_fk FOREIGN KEY (campaign_id) REFERENCES 
    "exerp"."startup_campaign" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT subscription_retention_campaign_to_subscriptions_fk FOREIGN KEY (subscription_center 
    , subscription_id) REFERENCES "exerp"."subscriptions" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
