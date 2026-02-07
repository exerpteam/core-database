CREATE TABLE 
    postal_address 
    ( 
        id int4 NOT NULL, 
        postal_code_id int4, 
        postal_area_id int4, 
        co_name        VARCHAR(200), 
        street_name    VARCHAR(200), 
        street_number  VARCHAR(50), 
        address_line_1 VARCHAR(200), 
        address_line_2 VARCHAR(200), 
        address_line_3 VARCHAR(200), 
        PRIMARY KEY (id), 
        CONSTRAINT poad_to_poar FOREIGN KEY (postal_area_id) REFERENCES "exerp"."postal_area" ("id" 
        ) ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT poad_to_poco FOREIGN KEY (postal_code_id) REFERENCES "exerp"."postal_code" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
