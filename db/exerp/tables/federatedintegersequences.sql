CREATE TABLE 
    federatedintegersequences 
    ( 
        center int4 NOT NULL, 
        name VARCHAR(32) NOT NULL, 
        allocincrement int4 DEFAULT 1 NOT NULL, 
        nextseq int4 NOT NULL, 
        PRIMARY KEY (center, name) 
    );
