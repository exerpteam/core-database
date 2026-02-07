CREATE TABLE 
    attends 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        start_time int8 NOT NULL, 
        stop_time int8, 
        attend_using_card bool, 
        STATE text(2147483647) NOT NULL, 
        booking_resource_center int4 NOT NULL, 
        booking_resource_id int4 NOT NULL, 
        person_center int4, 
        person_id int4, 
        employee_center int4, 
        employee_id int4, 
        last_modified int8, 
        origin int4, 
        PRIMARY KEY (center, id), 
        CONSTRAINT attends_to_book_res_fk FOREIGN KEY (booking_resource_center, booking_resource_id 
        ) REFERENCES "exerp"."booking_resources" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT attends_to_person_fk FOREIGN KEY (person_center, person_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
