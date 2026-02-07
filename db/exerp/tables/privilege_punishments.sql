CREATE TABLE 
    privilege_punishments 
    ( 
        id int4 NOT NULL, 
        name       text(2147483647) NOT NULL, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        STATE text(2147483647) NOT NULL, 
        restriction_count int4, 
        restriction_value int4, 
        restriction_unit int4, 
        restrict_by_access_group bool DEFAULT FALSE NOT NULL, 
        service_id text(2147483647) NOT NULL, 
        configuration bytea, 
        PRIMARY KEY (id) 
    );
