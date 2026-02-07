CREATE TABLE 
    jbm_id_cache 
    ( 
        node_id int4 NOT NULL, 
        cntr int4 NOT NULL, 
        jbm_id VARCHAR(255), 
        PRIMARY KEY (node_id, cntr) 
    );
