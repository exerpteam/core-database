CREATE TABLE 
    postal_area 
    ( 
        id int4 NOT NULL, 
        parent_id int4, 
        name             VARCHAR(200) NOT NULL, 
        alternative_name VARCHAR(200), 
        type             VARCHAR(50) NOT NULL, 
        country_id       VARCHAR(2) NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT poar_to_country FOREIGN KEY (country_id) REFERENCES "exerp"."countries" ("id") 
        ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT poar_to_parent FOREIGN KEY (parent_id) REFERENCES "exerp"."postal_area" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
