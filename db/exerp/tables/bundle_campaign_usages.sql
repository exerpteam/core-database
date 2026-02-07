CREATE TABLE 
    bundle_campaign_usages 
    ( 
        id serial DEFAULT nextval('bundle_campaign_usages_id_seq'::regclass) NOT NULL, 
        invoice_line_center int4 NOT NULL, 
        invoice_line_id int4 NOT NULL, 
        invoice_line_sub_id int4 NOT NULL, 
        campaign_id int4 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT bundle_campaign_usages_to_bundle_campaign FOREIGN KEY (campaign_id) REFERENCES 
        "exerp"."bundle_campaign" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT bundle_campaign_usages_to_invoice_lines_mt FOREIGN KEY (invoice_line_center, 
    invoice_line_id, invoice_line_sub_id) REFERENCES "exerp"."invoice_lines_mt" ("center", "id", 
    "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
