CREATE TABLE 
    push_device_tokens 
    ( 
        id int4 NOT NULL, 
        version int8, 
        person_center int4, 
        person_id int4, 
        platform     text(2147483647) NOT NULL, 
        environment  text(2147483647) NOT NULL, 
        device_token text(2147483647) NOT NULL, 
        register_date_time int8 NOT NULL, 
        PRIMARY KEY (id) 
    );
