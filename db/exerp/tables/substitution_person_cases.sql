CREATE TABLE 
    substitution_person_cases 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        substitute_center int4, 
        substitute_id int4, 
        e_mailed bool DEFAULT FALSE NOT NULL, 
        sms_ed bool DEFAULT FALSE NOT NULL, 
        mobiled bool DEFAULT FALSE NOT NULL, 
        phoned bool DEFAULT FALSE NOT NULL, 
        answer int4 NOT NULL, 
        PRIMARY KEY (center, id, subid) 
    );
