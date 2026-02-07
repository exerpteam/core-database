CREATE TABLE 
    persons 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        blacklisted int4 NOT NULL, 
        persontype int4 DEFAULT 0 NOT NULL, 
        status int4 DEFAULT 0 NOT NULL, 
        firstname     text(2147483647), 
        middlename    text(2147483647), 
        lastname      text(2147483647), 
        fullname      text(2147483647), 
        nickname      text(2147483647), 
        address1      text(2147483647), 
        address2      text(2147483647), 
        address3      text(2147483647), 
        country       text(2147483647), 
        zipcode       text(2147483647), 
        city          text(2147483647), 
        birthdate     DATE, 
        sex           text(2147483647) NOT NULL, 
        pincode       text(2147483647), 
        password_hash text(2147483647), 
        co_name       text(2147483647), 
        ssn           text(2147483647), 
        friends_allowance int4, 
        passwd_expiration       DATE, 
        first_active_start_date DATE, 
        last_active_start_date  DATE, 
        last_active_end_date    DATE, 
        memberdays int4 DEFAULT 0 NOT NULL, 
        accumulated_memberdays int4 DEFAULT 0 NOT NULL, 
        current_person_center int4, 
        current_person_id int4, 
        suspension_internal_note int4, 
        suspension_external_note int4, 
        external_id text(2147483647), 
        prefer_invoice_by_email bool DEFAULT FALSE NOT NULL, 
        member_status int4, 
        member_status_context int4, 
        password_reset_token text(2147483647), 
        password_reset_token_exp int8, 
        password_reset_token_used bool, 
        last_modified int8, 
        fullname_search tsvector, 
        transfers_current_prs_center int4, 
        STATE VARCHAR(60) DEFAULT 'NULL::character varying', 
        transfers_current_prs_id int4, 
        encrypted_ssn text(2147483647), 
        encryption_time int8, 
        national_id VARCHAR(100), 
        resident_id VARCHAR(100), 
        PRIMARY KEY (center, id), 
        CONSTRAINT person_to_center_fk FOREIGN KEY (center) REFERENCES "exerp"."centers" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT person_to_zipcode_fk FOREIGN KEY (country, zipcode, city) REFERENCES 
    "exerp"."zipcodes" ("country", "zipcode", "city") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
