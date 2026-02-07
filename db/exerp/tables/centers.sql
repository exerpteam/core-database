CREATE TABLE 
    centers 
    ( 
        id int4 NOT NULL, 
        shortname    text(2147483647) NOT NULL, 
        name         text(2147483647) NOT NULL, 
        startupdate  DATE, 
        phone_number text(2147483647), 
        fax_number   text(2147483647), 
        email        text(2147483647), 
        org_code     text(2147483647), 
        address1     text(2147483647), 
        address2     text(2147483647), 
        address3     text(2147483647), 
        country      text(2147483647), 
        zipcode      text(2147483647), 
        latitude     NUMERIC(0,0), 
        longitude    NUMERIC(0,0), 
        center_type int4 NOT NULL, 
        external_id text(2147483647), 
        city        text(2147483647), 
        org_code2   text(2147483647), 
        web_name    text(2147483647), 
        website_url text(2147483647), 
        manager_center int4, 
        manager_id int4, 
        asst_manager_center int4, 
        asst_manager_id int4, 
        last_modified int8, 
        time_zone    text(2147483647), 
        facility_url text(2147483647), 
        STATE        VARCHAR(60) DEFAULT 'NULL::character varying', 
        PRIMARY KEY (id), 
        CONSTRAINT center_to_country_fk FOREIGN KEY (country) REFERENCES "exerp"."countries" ("id") 
        ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT center_to_zipcode_fk FOREIGN KEY (country, zipcode, city) REFERENCES 
    "exerp"."zipcodes" ("country", "zipcode", "city") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
