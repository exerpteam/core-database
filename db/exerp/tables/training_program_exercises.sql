CREATE TABLE 
    training_program_exercises 
    ( 
        trainingprogram_center int4 NOT NULL, 
        trainingprogram_id int4 NOT NULL, 
        exercisetype_center int4 NOT NULL, 
        exercisetype_id int4 NOT NULL, 
        coment VARCHAR(240) NOT NULL, 
        prioroty int4, 
        CONSTRAINT tp_exercise_to_exercisetype_fk FOREIGN KEY (exercisetype_center, exercisetype_id 
        ) REFERENCES "exerp"."exercise_types" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT tp_exercise_to_tp_fk FOREIGN KEY (trainingprogram_center, trainingprogram_id) 
    REFERENCES "exerp"."training_programs" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
