CREATE TABLE 
    add_on_to_product_group_link 
    ( 
        add_on_product_definition_id int4 NOT NULL, 
        product_group_id int4 NOT NULL, 
        PRIMARY KEY (add_on_product_definition_id, product_group_id), 
        CONSTRAINT add_on_to_prg_to_aopd_fk FOREIGN KEY (add_on_product_definition_id) REFERENCES 
        "exerp"."add_on_product_definition" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT add_on_to_prg_to_prd_grp_fk FOREIGN KEY (product_group_id) REFERENCES 
    "exerp"."product_group" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
