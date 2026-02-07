CREATE TABLE 
    temp_chunk_file 
    ( 
        id int4 NOT NULL, 
        file_ref_id int4 DEFAULT 1 NOT NULL, 
        mime_value bytea NOT NULL, 
        created_time TIMESTAMP NOT NULL, 
        PRIMARY KEY (id) 
    );
