CREATE TABLE 
    zipcodes 
    ( 
        country  VARCHAR(2) NOT NULL, 
        zipcode  VARCHAR(8) NOT NULL, 
        city     VARCHAR(60) NOT NULL, 
        county   text(2147483647), 
        province text(2147483647), 
        PRIMARY KEY (country, zipcode, city), 
        CONSTRAINT zipcode_to_country_fk FOREIGN KEY (country) REFERENCES "exerp"."countries" ("id" 
        ) ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
