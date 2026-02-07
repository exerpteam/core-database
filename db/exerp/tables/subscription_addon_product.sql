CREATE TABLE 
    subscription_addon_product 
    ( 
        subscription_product_id int4 NOT NULL, 
        addon_product_id int4 NOT NULL, 
        PRIMARY KEY (subscription_product_id, addon_product_id), 
        CONSTRAINT spaopl_to_add_on_prod_def_fk FOREIGN KEY (addon_product_id) REFERENCES 
        "exerp"."add_on_product_definition" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT spaopl_to_sub_prod_def_fk FOREIGN KEY (subscription_product_id) REFERENCES 
    "exerp"."masterproductregister" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
