CREATE TABLE 
    exercise_types 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        name   text(2147483647) NOT NULL, 
        coment text(2147483647), 
        blocked bool NOT NULL, 
        image bytea, 
        descr text(2147483647), 
        available int4 NOT NULL, 
        PRIMARY KEY (center, id) 
    );
