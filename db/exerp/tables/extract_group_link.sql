CREATE TABLE 
    extract_group_link 
    ( 
        extract_id int4 NOT NULL, 
        group_id int4 NOT NULL, 
        PRIMARY KEY (extract_id, group_id), 
        CONSTRAINT exgrli_extract_id FOREIGN KEY (extract_id) REFERENCES "exerp"."extract" ("id") 
        ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT exgrli_group_fk FOREIGN KEY (group_id) REFERENCES "exerp"."extract_group" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
