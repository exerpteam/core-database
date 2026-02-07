CREATE TABLE 
    staff_bio 
    ( 
        id int4 NOT NULL, 
        staff_id int4 NOT NULL, 
        staff_center int4 NOT NULL, 
        creator_id int4 NOT NULL, 
        creator_center int4 NOT NULL, 
        description VARCHAR(200), 
        selling_points json, 
        created_at int8, 
        last_modified int8, 
        PRIMARY KEY (id) 
    );
