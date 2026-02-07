CREATE TABLE 
    booking_restrictions 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        start_time int8 NOT NULL, 
        stop_time int8, 
        user_interface_type int4, 
        in_advance_unit int4 DEFAULT 1 NOT NULL, 
        in_advance_value int4 DEFAULT 0 NOT NULL, 
        reason text(2147483647), 
        access_group int4, 
        has_expiry_been_notified bool DEFAULT FALSE, 
        prevent_all_bookings bool DEFAULT FALSE NOT NULL, 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT book_restr_to_person_fk FOREIGN KEY (center, id) REFERENCES "exerp"."persons" 
        ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
