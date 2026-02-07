CREATE TABLE 
    sms_splits 
    ( 
        sms_center int4 NOT NULL, 
        sms_id int4 NOT NULL, 
        ref_no VARCHAR(30) NOT NULL, 
        ok bool NOT NULL, 
        PRIMARY KEY (sms_center, sms_id, ref_no), 
        CONSTRAINT splits_to_sms_fk FOREIGN KEY (sms_center, sms_id) REFERENCES "exerp"."sms" 
        ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
