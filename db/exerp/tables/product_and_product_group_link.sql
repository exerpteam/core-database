CREATE TABLE 
    product_and_product_group_link 
    ( 
        product_center int4 NOT NULL, 
        product_id int4 NOT NULL, 
        product_group_id int4 NOT NULL, 
        PRIMARY KEY (product_center, product_id, product_group_id), 
        CONSTRAINT prd_and_prd_grp_to_prd_grp_fk FOREIGN KEY (product_group_id) REFERENCES 
        "exerp"."product_group" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT prd_and_prd_grp_to_prd_fk FOREIGN KEY (product_center, product_id) REFERENCES 
    "exerp"."products" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
