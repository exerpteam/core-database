CREATE TABLE 
    jbm_role 
    ( 
        role_id VARCHAR(32) NOT NULL, 
        user_id VARCHAR(32) NOT NULL, 
        PRIMARY KEY (user_id, role_id) 
    );
