CREATE TABLE 
    age_groups 
    ( 
        id int4 NOT NULL, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        name  text(2147483647), 
        STATE text(2147483647) NOT NULL, 
        min_age int4, 
        max_age int4, 
        external_id text(2147483647), 
        strict_min_age bool DEFAULT FALSE NOT NULL, 
        min_age_time_unit VARCHAR(6) DEFAULT 'YEAR'::character VARYING, 
        max_age_time_unit VARCHAR(6) DEFAULT 'YEAR'::character VARYING, 
        PRIMARY KEY (id) 
    );
