CREATE TABLE 
    shopping_basket_invoice_link 
    ( 
        shopping_basket_id int4 NOT NULL, 
        invoice_center int4 NOT NULL, 
        invoice_id int4 NOT NULL, 
        PRIMARY KEY (shopping_basket_id, invoice_center, invoice_id), 
        CONSTRAINT fk_invoices_center_id FOREIGN KEY (invoice_center, invoice_id) REFERENCES 
        "exerp"."invoices" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT fk_shopping_basket_id FOREIGN KEY (shopping_basket_id) REFERENCES 
    "exerp"."shopping_baskets" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
