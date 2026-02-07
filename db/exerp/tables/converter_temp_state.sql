CREATE TABLE 
    converter_temp_state 
    ( 
        entitytype VARCHAR(40) NOT NULL, 
        oldid      VARCHAR(255) NOT NULL, 
        newcenter int4 NOT NULL, 
        newid int4 NOT NULL, 
        newsubid int4 NOT NULL, 
        datatype    VARCHAR(20) NOT NULL, 
        lastupdated TIMESTAMP NOT NULL 
    );
