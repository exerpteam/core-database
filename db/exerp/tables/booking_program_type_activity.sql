CREATE TABLE 
    booking_program_type_activity 
    ( 
        id int4 NOT NULL, 
        booking_program_type_id int4 NOT NULL, 
        activity_id int4 NOT NULL, 
        product_global_id VARCHAR(30), 
        STATE             VARCHAR(10) DEFAULT 'ACTIVE'::character VARYING NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT bpta_to_activity_fk FOREIGN KEY (activity_id) REFERENCES "exerp"."activity" 
        ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT bpta_to_type_fk FOREIGN KEY (booking_program_type_id) REFERENCES 
    "exerp"."booking_program_types" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
