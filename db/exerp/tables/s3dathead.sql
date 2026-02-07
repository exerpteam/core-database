CREATE TABLE 
    s3dathead 
    ( 
        journalkey   VARCHAR(30) NOT NULL, 
        YEAR         VARCHAR(4), 
        MONTH        VARCHAR(2), 
        DAY          VARCHAR(2), 
        kindofdata   VARCHAR(10), 
        dateinserted VARCHAR(10), 
        timeinserted VARCHAR(8), 
        daterec      VARCHAR(10), 
        timerec      VARCHAR(8), 
        sora         VARCHAR(1), 
        costcenter   VARCHAR(15), 
        journaltxt   VARCHAR(30), 
        journalnum   VARCHAR(21), 
        countpos int4 
    );
