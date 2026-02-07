CREATE TABLE 
    s3datpos 
    ( 
        journalkey VARCHAR(30) NOT NULL, 
        linenum int4 NOT NULL, 
        transdate     VARCHAR(10), 
        debitaccount  VARCHAR(10), 
        creditaccount VARCHAR(10), 
        amount        NUMERIC(0,0), 
        txt           VARCHAR(30), 
        taxcode       VARCHAR(10) 
    );
