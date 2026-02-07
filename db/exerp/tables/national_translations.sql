CREATE TABLE 
    national_translations 
    ( 
        original_text VARCHAR(100) NOT NULL, 
        country       VARCHAR(2) NOT NULL, 
        translat      text(2147483647), 
        field int4 NOT NULL, 
        PRIMARY KEY (country, original_text) 
    );
