CREATE TABLE 
    booking_resource_usage 
    ( 
        booking_resource_center int4 NOT NULL, 
        booking_resource_id int4 NOT NULL, 
        booking_center int4 NOT NULL, 
        booking_id int4 NOT NULL, 
        configuration int4, 
        starttime int8 NOT NULL, 
        stoptime int8 NOT NULL, 
        STATE VARCHAR(10) NOT NULL, 
        conflict bool DEFAULT FALSE NOT NULL, 
        parent_booking_center int4, 
        parent_booking_id int4, 
        CONSTRAINT bru_to_conf_fk FOREIGN KEY (configuration) REFERENCES 
        "exerp"."activity_resource_configs" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT bru_to_book_res_fk FOREIGN KEY (booking_resource_center, booking_resource_id) 
    REFERENCES "exerp"."booking_resources" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT bru_to_book_fk FOREIGN KEY (booking_center, booking_id) REFERENCES 
    "exerp"."bookings" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT bru_to_parent_book_fk FOREIGN KEY (parent_booking_center, parent_booking_id) 
    REFERENCES "exerp"."bookings" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
