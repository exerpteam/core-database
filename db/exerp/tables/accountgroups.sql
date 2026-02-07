CREATE TABLE 
    accountgroups 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        name     text(2147483647) NOT NULL, 
        globalid text(2147483647), 
        PRIMARY KEY (center, id) 
    );
