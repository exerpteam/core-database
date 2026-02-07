CREATE TABLE 
    integration_hook 
    ( 
        id int4 NOT NULL, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        name   text(2147483647) NOT NULL, 
        status text(2147483647) NOT NULL, 
        plugin text(2147483647) NOT NULL, 
        config bytea, 
        PRIMARY KEY (id) 
    );
