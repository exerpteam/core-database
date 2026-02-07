CREATE TABLE 
    jbm_cluster 
    ( 
        node_id int4 NOT NULL, 
        ping_timestamp TIMESTAMP, 
        STATE int4, 
        PRIMARY KEY (node_id) 
    );
