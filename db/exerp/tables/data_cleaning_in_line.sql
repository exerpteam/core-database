CREATE TABLE 
    data_cleaning_in_line 
    ( 
        id int4 NOT NULL, 
        data_cleaning_in_id int4 NOT NULL, 
        person_center int4 NOT NULL, 
        person_id int4 NOT NULL, 
        line_type  text(2147483647) NOT NULL, 
        line_state text(2147483647) NOT NULL, 
        address_is_protected bool, 
        rejects_advertising bool, 
        first_name    text(2147483647), 
        middle_name   text(2147483647), 
        last_name     text(2147483647), 
        address_1     text(2147483647), 
        address_2     text(2147483647), 
        address_3     text(2147483647), 
        zip_code      text(2147483647), 
        zip_name      text(2147483647), 
        country       text(2147483647), 
        home_phone    text(2147483647), 
        mobile_phone  text(2147483647), 
        email_address text(2147483647), 
        birthday      DATE, 
        sex           text(2147483647), 
        status_date   DATE, 
        status        text(2147483647), 
        new_ssn       text(2147483647), 
        agency_id     text(2147483647), 
        co_name       text(2147483647), 
        PRIMARY KEY (id), 
        CONSTRAINT line_to_data_cleaning_in_fk FOREIGN KEY (data_cleaning_in_id) REFERENCES 
        "exerp"."data_cleaning_in" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT data_clean_in_line_to_pers_fk FOREIGN KEY (person_center, person_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
