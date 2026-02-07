CREATE TABLE 
    translations 
    ( 
        id int4 NOT NULL, 
        source_type   VARCHAR(100) NOT NULL, 
        source_key    VARCHAR(4000) NOT NULL, 
        language_type VARCHAR(50) NOT NULL, 
        translated    VARCHAR(4000) NOT NULL, 
        last_modified int8 NOT NULL, 
        last_modified_by_center int4 NOT NULL, 
        last_modified_by_id int4 NOT NULL, 
        PRIMARY KEY (id) 
    );
