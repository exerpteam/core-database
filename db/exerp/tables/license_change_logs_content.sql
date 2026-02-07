CREATE TABLE 
    license_change_logs_content 
    ( 
        id int4 NOT NULL, 
        license_change_log_id int4 NOT NULL, 
        license_id int4 NOT NULL, 
        change_type  text(2147483647) NOT NULL, 
        value_before text(2147483647), 
        value_after  text(2147483647), 
        PRIMARY KEY (id), 
        CONSTRAINT lclc_to_lcl_fk FOREIGN KEY (license_change_log_id) REFERENCES 
        "exerp"."license_change_logs" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT lclc_to_license_fk FOREIGN KEY (license_id) REFERENCES "exerp"."licenses" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
