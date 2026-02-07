CREATE TABLE 
    extract_and_apply_automations 
    ( 
        id int4 NOT NULL, 
        scope_type VARCHAR(1) NOT NULL, 
        scope_id int4 NOT NULL, 
        name        VARCHAR(60) NOT NULL, 
        description VARCHAR(200), 
        extract_id int4 NOT NULL, 
        apply_step_key int4 NOT NULL, 
        apply_step_configuration bytea, 
        PRIMARY KEY (id) 
    );
