CREATE TABLE 
    integersequences 
    ( 
        name VARCHAR(64) NOT NULL, 
        nextseq int4 NOT NULL, 
        allocincrement int4 DEFAULT 1 NOT NULL, 
        PRIMARY KEY (name) 
    );
