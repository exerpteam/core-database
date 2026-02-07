CREATE TABLE 
    favorite_searches 
    ( 
        id int4 NOT NULL, 
        person_center int4 NOT NULL, 
        person_id int4 NOT NULL, 
        mimetype VARCHAR(200) NOT NULL, 
        mimevalue bytea NOT NULL 
    );
