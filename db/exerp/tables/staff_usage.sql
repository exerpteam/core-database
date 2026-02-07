CREATE TABLE 
    staff_usage 
    ( 
        id int4 NOT NULL, 
        person_center int4, 
        person_id int4, 
        booking_center int4 NOT NULL, 
        booking_id int4 NOT NULL, 
        configuration int4, 
        starttime int8 NOT NULL, 
        stoptime int8 NOT NULL, 
        STATE text(2147483647) NOT NULL, 
        conflict bool DEFAULT FALSE NOT NULL, 
        salary NUMERIC(0,0), 
        parent_booking_center int4, 
        parent_booking_id int4, 
        available_for_substitution bool DEFAULT FALSE NOT NULL, 
        available_for_subst_time int8, 
        original_staff_center int4, 
        original_staff_id int4, 
        cancellation_time int8, 
        PRIMARY KEY (id), 
        CONSTRAINT su_to_conf_fk FOREIGN KEY (configuration) REFERENCES 
        "exerp"."activity_staff_configurations" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT su_to_book_fk FOREIGN KEY (booking_center, booking_id) REFERENCES "exerp"."bookings" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT su_to_parent_book_fk FOREIGN KEY (parent_booking_center, parent_booking_id) 
    REFERENCES "exerp"."bookings" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT su_to_person_fk FOREIGN KEY (person_center, person_id) REFERENCES "exerp"."persons" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
