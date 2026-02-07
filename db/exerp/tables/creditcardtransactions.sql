CREATE TABLE 
    creditcardtransactions 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        transtime int8 NOT NULL, 
        account_number text(2147483647), 
        type int4, 
        gl_trans_center int4, 
        gl_trans_id int4, 
        gl_trans_subid int4, 
        amount             NUMERIC(0,0) NOT NULL, 
        transaction_id     text(2147483647), 
        expiration_date    text(2147483647), 
        authorisation_code text(2147483647), 
        card_swiped bool, 
        transaction_state int4, 
        METHOD int4, 
        return_code             text(2147483647), 
        return_code_details     text(2147483647), 
        order_id                text(2147483647), 
        recurring_agreement_ref text(2147483647), 
        capture_type int4 DEFAULT 2, 
        cof_payment_agreement_center int4, 
        cof_payment_agreement_id int4, 
        cof_payment_agreement_subid int4, 
        approval_code  VARCHAR(50), 
        receipt_number VARCHAR(50), 
        invoice_center int4, 
        invoice_id int4, 
        account_id VARCHAR(20), 
        is_card_on_file bool, 
        last_modified int8 DEFAULT 0 NOT NULL, 
        PRIMARY KEY (center, id), 
        CONSTRAINT cct_invoice_fk FOREIGN KEY (invoice_center, invoice_id) REFERENCES 
        "exerp"."invoices" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
