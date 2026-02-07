CREATE TABLE 
    center_capacities 
    ( 
        id int4 NOT NULL, 
        checked_in_count int4 DEFAULT 0 NOT NULL, 
        reserved_spots int4 DEFAULT 0 NOT NULL, 
        PRIMARY KEY (id) 
    );
