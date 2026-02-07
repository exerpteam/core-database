CREATE TABLE 
    jbm_msg 
    ( 
        message_id int8 NOT NULL, 
        reliable bpchar(1), 
        expiration int8, 
        TIMESTAMP int8, 
        priority int2, 
        type int2, 
        headers bytea, 
        payload bytea, 
        PRIMARY KEY (message_id) 
    );
