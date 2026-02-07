CREATE TABLE 
    daily_member_status_changes 
    ( 
        id int4 NOT NULL, 
        person_center int4 NOT NULL, 
        person_id int4 NOT NULL, 
        change_date DATE NOT NULL, 
        change int4 NOT NULL, 
        member_number_delta int4 NOT NULL, 
        extra_number_delta int4 NOT NULL, 
        secondary_member_number_delta int4 NOT NULL, 
        entry_start_time int8 NOT NULL, 
        entry_stop_time int8, 
        PRIMARY KEY (id), 
        CONSTRAINT dmsc_to_persons_fk FOREIGN KEY (person_center, person_id) REFERENCES 
        "exerp"."persons" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
