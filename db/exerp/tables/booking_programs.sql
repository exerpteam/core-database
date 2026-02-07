CREATE TABLE 
    booking_programs 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        startdate   DATE NOT NULL, 
        stopdate    DATE NOT NULL, 
        name        text(2147483647), 
        description text(2147483647), 
        activity int4, 
        STATE text(2147483647) NOT NULL, 
        capacity int4, 
        waiting_list_capacity int4, 
        program_type_id int4, 
        cached_price NUMERIC(0,0), 
        cached_earliest_time int4, 
        cached_latest_time int4, 
        semester_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT courses_to_activities_fk FOREIGN KEY (activity) REFERENCES "exerp"."activity" 
        ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT bp_to_bpt_fk FOREIGN KEY (program_type_id) REFERENCES 
    "exerp"."booking_program_types" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT bp_to_sem_fk FOREIGN KEY (semester_id) REFERENCES "exerp"."semesters" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
