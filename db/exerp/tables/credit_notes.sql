CREATE TABLE 
    credit_notes 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        trans_time int8 NOT NULL, 
        employee_center int4, 
        employee_id int4, 
        cashregister_center int4, 
        cashregister_id int4, 
        paysessionid int4, 
        transferred bool DEFAULT FALSE NOT NULL, 
        entry_time int8 NOT NULL, 
        payer_center int4, 
        payer_id int4, 
        receipt_id int4, 
                          text text(2147483647), 
        control_device_id text(2147483647), 
        control_code      VARCHAR(500), 
        invoice_center int4, 
        invoice_id int4, 
        coment text(2147483647), 
        auditedbycenter int4, 
        auditedbyid int4, 
        canceltype int4, 
        cash bool DEFAULT FALSE NOT NULL, 
        fiscal_reference    VARCHAR(200), 
        fiscal_export_token VARCHAR(200), 
        clearance_status    VARCHAR(20) DEFAULT 'NOT_NEEDED'::character VARYING NOT NULL, 
        PRIMARY KEY (center, id), 
        CONSTRAINT creditnote_to_cashreg_fk FOREIGN KEY (cashregister_center, cashregister_id) 
        REFERENCES "exerp"."cashregisters" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT invoicallb_to_auditemp_fk FOREIGN KEY (auditedbycenter, auditedbyid) REFERENCES 
    "exerp"."employees" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT invoicallb_to_employee_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
    "exerp"."employees" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT invoicallb_to_invoice_fk FOREIGN KEY (invoice_center, invoice_id) REFERENCES 
    "exerp"."invoices" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT invoiceb_to_payer_fk FOREIGN KEY (payer_center, payer_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
