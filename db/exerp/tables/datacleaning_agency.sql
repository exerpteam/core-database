CREATE TABLE 
    datacleaning_agency 
    ( 
        id int4 NOT NULL, 
        plugin_id text(2147483647) NOT NULL, 
        name      text(2147483647) NOT NULL, 
        STATE     text(2147483647) NOT NULL, 
        configuration bytea, 
        scope_type text(2147483647), 
        scope_id int4, 
        PRIMARY KEY (id) 
    );
