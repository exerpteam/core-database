CREATE TABLE 
    booking_program_skills 
    ( 
        id int4 NOT NULL, 
        name text(2147483647) NOT NULL, 
        booking_program_level_id int4 NOT NULL, 
        STATE text(2147483647) NOT NULL, 
        rank int4, 
        create_time int8 NOT NULL, 
        update_time int8 NOT NULL, 
        update_employee_id int4 NOT NULL, 
        update_employee_center int4 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT skill_to_level_fk FOREIGN KEY (booking_program_level_id) REFERENCES 
        "exerp"."booking_program_levels" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT skill_to_upd_emp_fk FOREIGN KEY (update_employee_center, update_employee_id) 
    REFERENCES "exerp"."employees" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
