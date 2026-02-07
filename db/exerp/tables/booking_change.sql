CREATE TABLE 
    booking_change 
    ( 
        id int4 NOT NULL, 
        booking_center int4 NOT NULL, 
        booking_id int4 NOT NULL, 
        type text(2147483647) NOT NULL, 
             TIME int8 NOT NULL, 
        employee_center int4, 
        employee_id int4, 
        value_before text(2147483647), 
        value_after  text(2147483647), 
        PRIMARY KEY (id), 
        CONSTRAINT bl_to_book_fk FOREIGN KEY (booking_center, booking_id) REFERENCES 
        "exerp"."bookings" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT bl_to_employee_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
    "exerp"."employees" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
