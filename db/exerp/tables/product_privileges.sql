CREATE TABLE 
    product_privileges 
    ( 
        id int4 NOT NULL, 
        privilege_set int4, 
        valid_for text(2147483647) NOT NULL, 
        valid_from int8, 
        valid_to int8, 
        price_modification_name     text(2147483647), 
        price_modification_amount   NUMERIC(0,0), 
        price_modification_rounding text(2147483647), 
        ref_type                    text(2147483647) NOT NULL, 
        ref_globalid                text(2147483647), 
        ref_center int4, 
        ref_id int4, 
        disable_min_price bool DEFAULT FALSE NOT NULL, 
        purchase_right bool DEFAULT TRUE NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT prod_priv_to_priv_set FOREIGN KEY (privilege_set) REFERENCES 
        "exerp"."privilege_sets" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
