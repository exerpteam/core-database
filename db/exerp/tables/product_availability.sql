CREATE TABLE 
    product_availability 
    ( 
        id int4 NOT NULL, 
        product_master_key int4 NOT NULL, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT prod_avail_to_prod_master_fk FOREIGN KEY (product_master_key) REFERENCES 
        "exerp"."masterproductregister" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
