CREATE TABLE 
    event_conditions 
    ( 
        id int4 NOT NULL, 
        POSITION int4 NOT NULL, 
        event_configuration_id int4 NOT NULL, 
        type text(2147483647) NOT NULL, 
        PRIMARY KEY (id) 
    );
