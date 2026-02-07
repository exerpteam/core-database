CREATE TABLE 
    timeplaceresources 
    ( 
        timeplaceid int4 NOT NULL, 
        bookingresourceid int4 NOT NULL, 
        PRIMARY KEY (bookingresourceid, timeplaceid) 
    );
