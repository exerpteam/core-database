CREATE TABLE 
    payment_requests 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        STATE int4 NOT NULL, 
        request_type int4, 
        REF            text(2147483647), 
        full_reference text(2147483647), 
        req_amount     NUMERIC(0,0) NOT NULL, 
        req_date       DATE NOT NULL, 
        req_delivery int4, 
        inv_coll_center int4, 
        inv_coll_id int4, 
        inv_coll_subid int4, 
        reject_fee_invline_center int4, 
        reject_fee_invline_id int4, 
        reject_fee_invline_subid int4, 
        xfr_amount NUMERIC(0,0), 
        xfr_date   DATE, 
        xfr_delivery int4, 
        xfr_info text(2147483647), 
        clearinghouse_id int4, 
        creditor_id text(2147483647), 
        agr_subid int4, 
        formatted_doc_mimetype text(2147483647), 
        formatted_doc_mimevalue bytea, 
        coll_fee_invline_center int4, 
        coll_fee_invline_id int4, 
        coll_fee_invline_subid int4, 
        due_date DATE, 
        entry_time int8, 
        rejected_reason_code text(2147483647), 
        uuid                 text(2147483647), 
        employee_center int4, 
        employee_id int4, 
        notification_type int4, 
        invoice_created_at int8, 
        invoice_created_by_emp_center int4, 
        invoice_created_by_emp_id int4, 
        handler_type text(2147483647) DEFAULT 'FILE'::text NOT NULL, 
        last_modified int8, 
        specification_doc_mimetype text(2147483647), 
        specification_doc_mimevalue bytea, 
        clearinghouse_payment_ref text(2147483647), 
        s3key_formatted_doc       text(2147483647), 
        s3bucket_formatted_doc    text(2147483647), 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT payment_req_to_ar_fk FOREIGN KEY (center, id) REFERENCES 
        "exerp"."account_receivables" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT payment_req_to_clearin_fk FOREIGN KEY (xfr_delivery) REFERENCES 
    "exerp"."clearing_in" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT payment_req_to_clearout_fk FOREIGN KEY (req_delivery) REFERENCES 
    "exerp"."clearing_out" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT req_to_cred_fk FOREIGN KEY (clearinghouse_id, creditor_id) REFERENCES 
    "exerp"."clearinghouse_creditors" ("clearinghouse", "creditor_id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT payment_req_to_il_fk FOREIGN KEY (coll_fee_invline_center, coll_fee_invline_id, 
    coll_fee_invline_subid) REFERENCES "exerp"."invoice_lines_mt" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT payment_req_to_rej_fk FOREIGN KEY (reject_fee_invline_center, reject_fee_invline_id, 
    reject_fee_invline_subid) REFERENCES "exerp"."invoice_lines_mt" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT payment_req_to_pa_fk FOREIGN KEY (center, id) REFERENCES "exerp"."payment_accounts" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT payment_req_to_pay_req_spec_fk FOREIGN KEY (inv_coll_center, inv_coll_id, 
    inv_coll_subid) REFERENCES "exerp"."payment_request_specifications" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
