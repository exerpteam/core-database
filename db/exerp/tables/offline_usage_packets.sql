CREATE TABLE 
    offline_usage_packets 
    ( 
        id int4 NOT NULL, 
        external_id text(2147483647) NOT NULL, 
        received int8, 
        client_id int4 NOT NULL, 
        status int4 NOT NULL, 
        PRIMARY KEY (id) 
    );
