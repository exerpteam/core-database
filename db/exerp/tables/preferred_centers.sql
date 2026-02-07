CREATE TABLE 
    preferred_centers 
    ( 
        person_center int4 NOT NULL, 
        person_id int4 NOT NULL, 
        preferred_center int4 NOT NULL, 
        PRIMARY KEY (person_center, person_id, preferred_center) 
    );
