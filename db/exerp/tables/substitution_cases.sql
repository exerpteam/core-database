CREATE TABLE 
    substitution_cases 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        booking_center int4, 
        booking_id int4, 
        closed bool DEFAULT FALSE NOT NULL, 
        absentee_center int4, 
        absentee_id int4, 
        PRIMARY KEY (center, id) 
    );
