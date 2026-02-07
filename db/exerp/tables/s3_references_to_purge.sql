CREATE TABLE 
    s3_references_to_purge 
    ( 
        s3bucket VARCHAR(64) NOT NULL, 
        s3key    VARCHAR(1024) NOT NULL, 
        entity   VARCHAR(64) NOT NULL, 
        deleted_in_s3 int8, 
        deleted_in_db int8 NOT NULL, 
        status int4 NOT NULL, 
        person_center int4, 
        person_id int4, 
        PRIMARY KEY (s3bucket, s3key) 
    );
