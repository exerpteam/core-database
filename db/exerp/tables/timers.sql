CREATE TABLE 
    timers 
    ( 
        timerid  VARCHAR(80) NOT NULL, 
        targetid VARCHAR(250) NOT NULL, 
        initialdate timestamptz NOT NULL, 
        nextdate timestamptz, 
        timerinterval int8, 
        instancepk bytea, 
        info bytea, 
        PRIMARY KEY (timerid, targetid) 
    );
