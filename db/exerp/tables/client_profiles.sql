CREATE TABLE 
    client_profiles 
    ( 
        id int4 NOT NULL, 
        profile_name text(2147483647) NOT NULL, 
        scope_type   text(2147483647), 
        scope_id int4, 
        configuration bytea, 
        client_type text(2147483647) DEFAULT 'CLIENT'::text NOT NULL, 
        PRIMARY KEY (id) 
    );
