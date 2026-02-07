CREATE TABLE 
    countries 
    ( 
        id   VARCHAR(2) NOT NULL, 
        name text(2147483647), 
        area int4, 
        defaultlanguage text(2147483647), 
        defaulttimezone text(2147483647), 
        last_modified int8, 
        PRIMARY KEY (id) 
    );
