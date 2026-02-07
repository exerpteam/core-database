CREATE TABLE 
    training_programs 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        person_center int4 NOT NULL, 
        person_id int4 NOT NULL, 
        creator_center int4 NOT NULL, 
        creator_id int4 NOT NULL, 
        creation_date DATE NOT NULL, 
        active bool NOT NULL, 
        PRIMARY KEY (center, id), 
        CONSTRAINT train_prog_to_emp_fk FOREIGN KEY (creator_center, creator_id) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT train_prog_to_person_fk FOREIGN KEY (person_center, person_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
