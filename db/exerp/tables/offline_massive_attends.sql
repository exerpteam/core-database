CREATE TABLE 
    offline_massive_attends 
    ( 
        id int4 NOT NULL, 
        person_center int4 NOT NULL, 
        person_id int4 NOT NULL, 
        TIMESTAMP int8 NOT NULL, 
        resource_center int4 NOT NULL, 
        resource_id int4 NOT NULL, 
        identity_method int4, 
        PRIMARY KEY (id) 
    );
