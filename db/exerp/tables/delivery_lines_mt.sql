CREATE TABLE 
    delivery_lines_mt 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        product_center int4 NOT NULL, 
        product_id int4 NOT NULL, 
        quantity int4 NOT NULL, 
        number_of_parcels int4 NOT NULL, 
        items_per_parcel int4 NOT NULL, 
        total_cost_price NUMERIC(0,0) NOT NULL, 
        manual_cost_price bool NOT NULL, 
        coment text(2147483647), 
        error bool DEFAULT FALSE NOT NULL, 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT delivery_line_to_center_fk FOREIGN KEY (center) REFERENCES "exerp"."centers" 
        ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT delivery_line_to_delivery_fk FOREIGN KEY (center, id) REFERENCES "exerp"."delivery" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT delivery_line_to_product_fk FOREIGN KEY (product_center, product_id) REFERENCES 
    "exerp"."products" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
