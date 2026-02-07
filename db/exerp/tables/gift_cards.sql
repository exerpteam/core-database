CREATE TABLE 
    gift_cards 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        STATE int4 NOT NULL, 
        amount NUMERIC(0,0) NOT NULL, 
        product_center int4, 
        product_id int4, 
        invoiceline_center int4, 
        invoiceline_id int4, 
        invoiceline_subid int4, 
        expirationdate DATE NOT NULL, 
        use_time int8, 
        purchase_time int8, 
        payer_center int4, 
        payer_id int4, 
        amount_remaining NUMERIC(0,0), 
        last_modified int8, 
        PRIMARY KEY (center, id), 
        CONSTRAINT giftcards_to_involine_fk FOREIGN KEY (invoiceline_center, invoiceline_id, 
        invoiceline_subid) REFERENCES "exerp"."invoice_lines_mt" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT giftcards_to_products_fk FOREIGN KEY (product_center, product_id) REFERENCES 
    "exerp"."products" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
