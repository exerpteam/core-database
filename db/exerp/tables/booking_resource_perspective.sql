CREATE TABLE 
    booking_resource_perspective 
    ( 
        id int4 NOT NULL, 
        center_key int4 NOT NULL, 
        name          text(2147483647) NOT NULL, 
        resource_keys text(2147483647) NOT NULL, 
        PRIMARY KEY (id) 
    );
