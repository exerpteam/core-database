CREATE TABLE 
    booking_program_levels 
    ( 
        id int4 NOT NULL, 
        external_id text(2147483647), 
        name        text(2147483647), 
        STATE       text(2147483647) NOT NULL, 
        rank int4, 
        booking_program_type_id int4 NOT NULL, 
        required_showup int4 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT program_levels_to_types_fk FOREIGN KEY (booking_program_type_id) REFERENCES 
        "exerp"."booking_program_types" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
