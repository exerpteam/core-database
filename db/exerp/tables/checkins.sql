CREATE TABLE 
    checkins 
    ( 
        id int4 NOT NULL, 
        person_center int4, 
        person_id int4, 
        checkin_center int4 NOT NULL, 
        checkin_time int8 NOT NULL, 
        checkout_time int8, 
        checked_out bool, 
        card_checked_in bool, 
        checkin_result int4 DEFAULT 0 NOT NULL, 
        identity_method int4, 
        last_modified int8, 
        origin int4, 
        checkout_reminder_count int4 DEFAULT 0 NOT NULL, 
        person_type int4 DEFAULT 0 NOT NULL, 
        checkin_failed_reason VARCHAR(50), 
        PRIMARY KEY (id), 
        CONSTRAINT checkins_to_person_fk FOREIGN KEY (person_center, person_id) REFERENCES 
        "exerp"."persons" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
