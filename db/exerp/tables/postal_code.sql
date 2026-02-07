CREATE TABLE 
    postal_code 
    ( 
        id int4 NOT NULL, 
        code       VARCHAR(100) NOT NULL, 
        country_id VARCHAR(2) NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT poco_to_country FOREIGN KEY (country_id) REFERENCES "exerp"."countries" ("id") 
        ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
