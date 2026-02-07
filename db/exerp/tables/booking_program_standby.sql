CREATE TABLE 
    booking_program_standby 
    ( 
        id int4 NOT NULL, 
        participant_center int4 NOT NULL, 
        participant_id int4 NOT NULL, 
        owner_center int4, 
        owner_id int4, 
        created_by_employee_center int4, 
        created_by_employee_id int4, 
        start_booking_center int4 NOT NULL, 
        start_booking_id int4 NOT NULL, 
        creation_time int8 NOT NULL, 
        creation_interface_type int4, 
        cancelation_time int8, 
        PRIMARY KEY (id), 
        CONSTRAINT bps_to_bookings_fk FOREIGN KEY (start_booking_center, start_booking_id) 
        REFERENCES "exerp"."bookings" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT bps_to_created_by_employee_fk FOREIGN KEY (created_by_employee_center, 
    created_by_employee_id) REFERENCES "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT bps_to_owner_fk FOREIGN KEY (owner_center, owner_id) REFERENCES "exerp"."persons" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT bps_to_participant_fk FOREIGN KEY (participant_center, participant_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
