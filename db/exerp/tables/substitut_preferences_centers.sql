CREATE TABLE 
    substitut_preferences_centers 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        foreign_center_id int4 NOT NULL, 
        travel_time int4 NOT NULL, 
        PRIMARY KEY (center, id, subid) 
    );
