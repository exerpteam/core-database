CREATE TABLE 
    payment_request_specifications 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        entry_time int8, 
        requested_amount NUMERIC(0,0), 
        collection_fee   NUMERIC(0,0) DEFAULT 0 NOT NULL, 
        rejection_fee    NUMERIC(0,0) DEFAULT 0 NOT NULL, 
        cancelled bool DEFAULT FALSE NOT NULL, 
        REF                  text(2147483647), 
                             text text(2147483647), 
        original_due_date    DATE, 
        total_invoice_amount NUMERIC(0,0), 
        from_date int8, 
        to_date int8, 
        balance_from            NUMERIC(0,0), 
        balance_to              NUMERIC(0,0), 
        included_overdue_amount NUMERIC(0,0), 
        open_amount             NUMERIC(0,0) DEFAULT 0 NOT NULL, 
        paid_state              text(2147483647) NOT NULL, 
        paid_state_last_entry_time int8 DEFAULT 0 NOT NULL, 
        inv_diff NUMERIC(0,0), 
        last_modified int8, 
        issued_date int8, 
        fiscal_reference    VARCHAR(200), 
        fiscal_export_token VARCHAR(200), 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT payment_req_spec_to_ar_fk FOREIGN KEY (center, id) REFERENCES 
        "exerp"."account_receivables" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
