CREATE TABLE 
    frequent_products_item 
    ( 
        rank int4 NOT NULL, 
        frequent_products_list_id int4 NOT NULL, 
        product_id int4 NOT NULL, 
        version int8, 
        PRIMARY KEY (frequent_products_list_id, product_id), 
        CONSTRAINT item_to_freq_products_list_fk FOREIGN KEY (frequent_products_list_id) REFERENCES 
        "exerp"."frequent_products_list" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT freq_prod_item_to_mast_prod_fk FOREIGN KEY (product_id) REFERENCES 
    "exerp"."masterproductregister" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
