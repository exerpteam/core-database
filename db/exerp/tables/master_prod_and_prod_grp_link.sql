CREATE TABLE 
    master_prod_and_prod_grp_link 
    ( 
        master_product_id int4 NOT NULL, 
        product_group_id int4 NOT NULL, 
        PRIMARY KEY (master_product_id, product_group_id), 
        CONSTRAINT m_prd_n_prd_grp_to_m_prd_fk FOREIGN KEY (master_product_id) REFERENCES 
        "exerp"."masterproductregister" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT m_prd_n_prd_grp_to_prd_grp_fk FOREIGN KEY (product_group_id) REFERENCES 
    "exerp"."product_group" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
