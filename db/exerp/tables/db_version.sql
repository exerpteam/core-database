CREATE TABLE 
    db_version 
    ( 
        id int4 NOT NULL, 
        major int4 NOT NULL, 
        minor int4 NOT NULL, 
        revision int4 NOT NULL, 
        starttime int8 NOT NULL, 
        customer text(2147483647) NOT NULL, 
        PRIMARY KEY (id) 
    );
