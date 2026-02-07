CREATE TABLE 
    credit_note_lines_mt 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        invoiceline_center int4, 
        invoiceline_id int4, 
        invoiceline_subid int4, 
        productcenter int4 NOT NULL, 
        productid int4 NOT NULL, 
        person_center int4, 
        person_id int4, 
        account_trans_center int4, 
        account_trans_id int4, 
        account_trans_subid int4, 
        quantity int4 NOT NULL, 
        text text(2147483647), 
        credit_type int4 NOT NULL, 
        canceltype int4, 
        total_amount NUMERIC(0,0), 
        product_cost NUMERIC(0,0), 
        reason int4 NOT NULL, 
        installment_plan_id int4, 
        cancel_reason text(2147483647), 
        rebooking_acc_trans_center int4, 
        rebooking_acc_trans_id int4, 
        rebooking_acc_trans_subid int4, 
        rebooking_to_center int4, 
        net_amount NUMERIC(0,0), 
        sales_commission int4, 
        sales_units int4, 
        period_commission int4, 
        flat_rate_commission NUMERIC(0,0), 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT credline_to_acctrans_fk FOREIGN KEY (account_trans_center, account_trans_id, 
        account_trans_subid) REFERENCES "exerp"."account_trans" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT credline_to_center_fk FOREIGN KEY (center) REFERENCES "exerp"."centers" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT credline_to_crednote_fk FOREIGN KEY (center, id) REFERENCES "exerp"."credit_notes" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT credline_to_ip_fk FOREIGN KEY (installment_plan_id) REFERENCES 
    "exerp"."installment_plans" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT credline_to_invline_fk FOREIGN KEY (invoiceline_center, invoiceline_id, 
    invoiceline_subid) REFERENCES "exerp"."invoice_lines_mt" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT credline_to_product_fk FOREIGN KEY (productcenter, productid) REFERENCES 
    "exerp"."products" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
