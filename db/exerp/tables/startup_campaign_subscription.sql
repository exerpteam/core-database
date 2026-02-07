CREATE TABLE 
    startup_campaign_subscription 
    ( 
        id int4 NOT NULL, 
        startup_campaign int4, 
        ref_type     text(2147483647) NOT NULL, 
        ref_globalid text(2147483647), 
        ref_center int4, 
        ref_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT scs_to_sc_fk FOREIGN KEY (startup_campaign) REFERENCES 
        "exerp"."startup_campaign" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
