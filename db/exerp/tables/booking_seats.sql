CREATE TABLE 
    booking_seats 
    ( 
        id int4 NOT NULL, 
        REF text(2147483647) NOT NULL, 
        resource_center int4 NOT NULL, 
        resource_id int4 NOT NULL, 
        x      NUMERIC(0,0) NOT NULL, 
        y      NUMERIC(0,0) NOT NULL, 
        status text(2147483647) NOT NULL, 
        PRIMARY KEY (id) 
    );
