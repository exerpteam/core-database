CREATE TABLE 
    jbm_postoffice 
    ( 
        postoffice_name VARCHAR(255) NOT NULL, 
        node_id int4 NOT NULL, 
        queue_name VARCHAR(255) NOT NULL, 
        cond       VARCHAR(1023), 
        selector   VARCHAR(1023), 
        channel_id int8, 
        clustered bpchar(1), 
        all_nodes bpchar(1), 
        PRIMARY KEY (postoffice_name, node_id, queue_name) 
    );
