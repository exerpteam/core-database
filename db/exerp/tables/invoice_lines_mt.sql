CREATE TABLE 
    invoice_lines_mt 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        productcenter int4 NOT NULL, 
        productid int4 NOT NULL, 
        person_center int4, 
        person_id int4, 
        account_trans_center int4, 
        account_trans_id int4, 
        account_trans_subid int4, 
        quantity int4 NOT NULL, 
                             text text(2147483647), 
        product_cost         NUMERIC(0,0), 
        product_normal_price NUMERIC(0,0), 
        total_amount         NUMERIC(0,0), 
        sales_type int4 DEFAULT 0 NOT NULL, 
        remove_from_inventory bool DEFAULT FALSE NOT NULL, 
        reason int4 NOT NULL, 
        sponsor_invoice_subid int4, 
        installment_plan_id int4, 
        net_amount NUMERIC(0,0), 
        rebooking_acc_trans_center int4, 
        rebooking_acc_trans_id int4, 
        rebooking_acc_trans_subid int4, 
        rebooking_to_center int4, 
        sales_commission int4, 
        sales_units int4, 
        period_commission int4, 
        flat_rate_commission NUMERIC(0,0), 
        external_id          VARCHAR(100), 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT invoiceline_to_acctrans_fk FOREIGN KEY (account_trans_center, account_trans_id, 
        account_trans_subid) REFERENCES "exerp"."account_trans" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT invoiceline_to_center_fk FOREIGN KEY (center) REFERENCES "exerp"."centers" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT invline_to_install_plans_fk FOREIGN KEY (installment_plan_id) REFERENCES 
    "exerp"."installment_plans" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT invoiceline_to_invoice_fk FOREIGN KEY (center, id) REFERENCES "exerp"."invoices" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT invoiceline_to_person_fk FOREIGN KEY (person_center, person_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT invoiceline_to_product_fk FOREIGN KEY (productcenter, productid) REFERENCES 
    "exerp"."products" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
