CREATE TABLE 
    qrtz_calendars 
    ( 
        calendar_name VARCHAR(200) NOT NULL, 
        calendar bytea NOT NULL, 
        PRIMARY KEY (calendar_name) 
    );
