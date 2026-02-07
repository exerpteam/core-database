CREATE TABLE 
    ar_trans 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        trans_time int8 NOT NULL, 
        employeecenter int4, 
        employeeid int4, 
        amount   NUMERIC(0,0) NOT NULL, 
        due_date DATE, 
        info     text(2147483647), 
                 text text(2147483647), 
        transferred bool DEFAULT FALSE NOT NULL, 
        entry_time int8 NOT NULL, 
        payreq_spec_center int4, 
        payreq_spec_id int4, 
        payreq_spec_subid int4, 
        collected int4 NOT NULL, 
        ref_type text(2147483647), 
        ref_center int4, 
        ref_id int4, 
        ref_subid int4, 
        status           text(2147483647), 
        match_info       text(2147483647), 
        unsettled_amount NUMERIC(0,0), 
        collected_amount NUMERIC(0,0), 
        installment_plan_id int4, 
        installment_plan_subindex int4, 
        collect_agreement_center int4, 
        collect_agreement_id int4, 
        collect_agreement_subid int4, 
        last_modified int8, 
        collection_mode int4, 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT ar_trans_to_ar_fk FOREIGN KEY (center, id) REFERENCES 
        "exerp"."account_receivables" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ar_trans_to_employee_fk FOREIGN KEY (employeecenter, employeeid) REFERENCES 
    "exerp"."employees" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ar_trans_to_install_plans_fk FOREIGN KEY (installment_plan_id) REFERENCES 
    "exerp"."installment_plans" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ar_trans_to_collect_pag_fk FOREIGN KEY (collect_agreement_center, 
    collect_agreement_id, collect_agreement_subid) REFERENCES "exerp"."payment_agreements" 
    ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ar_trans_to_pay_req_spec_fk FOREIGN KEY (payreq_spec_center, payreq_spec_id, 
    payreq_spec_subid) REFERENCES "exerp"."payment_request_specifications" ("center", "id", "subid" 
    ) 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
