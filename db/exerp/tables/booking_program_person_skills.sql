CREATE TABLE 
    booking_program_person_skills 
    ( 
        id int4 NOT NULL, 
        person_center int4 NOT NULL, 
        person_id int4 NOT NULL, 
        booking_program_skill_id int4 NOT NULL, 
        create_time int8 NOT NULL, 
        update_time int8, 
        update_employee_id int4, 
        update_employee_center int4, 
        comments text(2147483647), 
        create_employee_center int4, 
        create_employee_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT cps_to_course_skill_fk FOREIGN KEY (booking_program_skill_id) REFERENCES 
        "exerp"."booking_program_skills" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cps_to_create_emp_fk FOREIGN KEY (create_employee_center, create_employee_id) 
    REFERENCES "exerp"."employees" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cps_to_employee_fk FOREIGN KEY (update_employee_center, update_employee_id) 
    REFERENCES "exerp"."employees" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cps_to_person_fk FOREIGN KEY (person_center, person_id) REFERENCES "exerp"."persons" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
