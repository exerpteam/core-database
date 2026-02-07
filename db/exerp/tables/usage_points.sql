CREATE TABLE 
    usage_points 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        STATE text(2147483647) NOT NULL, 
        name  text(2147483647) NOT NULL, 
        all_clients bool DEFAULT FALSE NOT NULL, 
        all_kiosks bool DEFAULT FALSE NOT NULL, 
        PRIMARY KEY (center, id) 
    );
