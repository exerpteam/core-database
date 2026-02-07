CREATE TABLE 
    recurring_participations 
    ( 
        id int4 NOT NULL, 
        booking_program_id int4 NOT NULL, 
        participant_center int4 NOT NULL, 
        participant_id int4 NOT NULL, 
        STATE VARCHAR(50) NOT NULL, 
        subscription_id int4, 
        subscription_center int4, 
        start_time int8 NOT NULL, 
        end_time int8, 
        installment_plan_id int4, 
        owner_center int4, 
        owner_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT rec_participation_to_course_fk FOREIGN KEY (booking_program_id) REFERENCES 
        "exerp"."booking_programs" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT rec_participation_to_ip_fk FOREIGN KEY (installment_plan_id) REFERENCES 
    "exerp"."installment_plans" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT rec_participation_to_person_fk FOREIGN KEY (participant_center, participant_id) 
    REFERENCES "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT rec_participation_to_sub_fk FOREIGN KEY (subscription_center, subscription_id) 
    REFERENCES "exerp"."subscriptions" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
