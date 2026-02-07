CREATE TABLE 
    vending_machine_slide 
    ( 
        id int4 NOT NULL, 
        vending_machine int4 NOT NULL, 
        name text(2147483647) NOT NULL, 
        product_center int4 NOT NULL, 
        product_id int4 NOT NULL, 
        product_capacity int4 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT vend_mach_slide_to_product_fk FOREIGN KEY (product_center, product_id) 
        REFERENCES "exerp"."products" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT vend_mach_slde_to_vend_mach_fk FOREIGN KEY (vending_machine) REFERENCES 
    "exerp"."vending_machine" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
