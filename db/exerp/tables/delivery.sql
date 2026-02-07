CREATE TABLE 
    delivery 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        supplier_center int4 NOT NULL, 
        supplier_id int4 NOT NULL, 
        invoice_no    text(2147483647), 
        order_no      text(2147483647), 
        delivery_date DATE NOT NULL, 
        entry_time int8 NOT NULL, 
        shipping_cost NUMERIC(0,0), 
        employee_center int4 NOT NULL, 
        employee_id int4 NOT NULL, 
        coment text(2147483647), 
        inventory int4 NOT NULL, 
        payment_trans_center int4, 
        payment_trans_id int4, 
        payment_trans_subid int4, 
        paid_amount     NUMERIC(0,0), 
        paid_date       DATE, 
        delivery_amount NUMERIC(0,0), 
        PRIMARY KEY (center, id), 
        CONSTRAINT delivery_to_center_fk FOREIGN KEY (center) REFERENCES "exerp"."centers" ("id") 
        ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT delivery_to_employee_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
    "exerp"."employees" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT dly_to_in_fk FOREIGN KEY (inventory) REFERENCES "exerp"."inventory" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT delivery_to_company_fk FOREIGN KEY (supplier_center, supplier_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT delivery_to_supplier_fk FOREIGN KEY (supplier_center, supplier_id) REFERENCES 
    "exerp"."supplier" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
