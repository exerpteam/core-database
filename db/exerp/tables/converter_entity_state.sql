CREATE TABLE 
    converter_entity_state 
    ( 
        entitytype  VARCHAR(40) NOT NULL, 
        oldentityid VARCHAR(255) NOT NULL, 
        newentitycenter int4 NOT NULL, 
        newentityid int4 NOT NULL, 
        newentitysubid int4, 
        writername  VARCHAR(40) NOT NULL, 
        lastupdated TIMESTAMP NOT NULL 
    );
