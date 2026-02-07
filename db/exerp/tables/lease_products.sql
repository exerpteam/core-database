CREATE TABLE 
    lease_products 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        max_minutes int4 NOT NULL, 
        instructor_count int4 NOT NULL, 
        PRIMARY KEY (center, id), 
        CONSTRAINT lease_to_product_fk FOREIGN KEY (center, id) REFERENCES "exerp"."products" 
        ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
