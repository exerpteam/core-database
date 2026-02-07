CREATE TABLE 
    bundle_campaign_product 
    ( 
        id int4 NOT NULL, 
        bundle_campaign int4, 
        rebated bool NOT NULL, 
        ref_type     text(2147483647) NOT NULL, 
        ref_globalid text(2147483647), 
        ref_center int4, 
        ref_id int4, 
        units int4, 
        PRIMARY KEY (id), 
        CONSTRAINT bcs_to_bc_fk FOREIGN KEY (bundle_campaign) REFERENCES "exerp"."bundle_campaign" 
        ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
