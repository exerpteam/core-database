CREATE TABLE 
    federatedintegersubsequences 
    ( 
        center int4 NOT NULL, 
        name VARCHAR(32) NOT NULL, 
        seq int4 NOT NULL, 
        subname VARCHAR(32) NOT NULL, 
        allocincrement int4 DEFAULT 1 NOT NULL, 
        nextsubseq int4 NOT NULL, 
        PRIMARY KEY (center, name, seq, subname) 
    );
