CREATE TABLE 
    jbm_user 
    ( 
        user_id  VARCHAR(32) NOT NULL, 
        passwd   VARCHAR(32) NOT NULL, 
        clientid VARCHAR(128), 
        PRIMARY KEY (user_id) 
    );
