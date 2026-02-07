CREATE TABLE 
    postal_code_area_mapping 
    ( 
        postal_code_id int4 NOT NULL, 
        postal_area_id int4 NOT NULL, 
        PRIMARY KEY (postal_code_id, postal_area_id), 
        CONSTRAINT poam_to_poar FOREIGN KEY (postal_area_id) REFERENCES "exerp"."postal_area" ("id" 
        ) ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT poam_to_poco FOREIGN KEY (postal_code_id) REFERENCES "exerp"."postal_code" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
