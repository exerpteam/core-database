CREATE TABLE 
    payment_agreements 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        STATE int4 NOT NULL, 
        active bool NOT NULL, 
        REF text(2147483647) NOT NULL, 
        clearinghouse int4, 
        creditor_id         text(2147483647), 
        bank_regno          text(2147483647), 
        bank_branch_no      text(2147483647), 
        bank_name           text(2147483647), 
        bank_control_digits text(2147483647), 
        bank_accno          text(2147483647), 
        bank_account_holder text(2147483647), 
        extra_info          text(2147483647), 
        request_serial int4 NOT NULL, 
        requests_sent int4 NOT NULL, 
        clearinghouse_ref text(2147483647), 
        creation_time int8, 
        iban text(2147483647), 
        bic  text(2147483647), 
        notify_payment bool DEFAULT FALSE NOT NULL, 
        maximum_deduction_amount  NUMERIC(0,0), 
        standard_deduction_amount NUMERIC(0,0), 
        payment_cycle_config_id int4 NOT NULL, 
        individual_deduction_day int4, 
        expiration_date DATE, 
        expiration_notified bool, 
        prev_center int4, 
        prev_id int4, 
        prev_subid int4, 
        current_center int4, 
        current_id int4, 
        current_subid int4, 
        ended_reason_code text(2147483647), 
        ended_reason_text text(2147483647), 
        ended_date        DATE, 
        ended_clearing_in int4, 
        valid_agreement_change bool DEFAULT FALSE NOT NULL, 
        deduction_day_changed DATE, 
        pr_approval_enabled bool, 
        pr_auto_approval_enabled bool DEFAULT FALSE NOT NULL, 
        pr_auto_approval_lower_pct int4 DEFAULT 80 NOT NULL, 
        pr_auto_approval_upper_pct int4 DEFAULT 120 NOT NULL, 
        ignore_missing_agreement bool DEFAULT FALSE NOT NULL, 
        account_type                text(2147483647), 
        example_reference           text(2147483647), 
        bank_account_details        text(2147483647), 
        clearinghouse_init_ref      text(2147483647), 
        bank_account_number_hash    text(2147483647), 
        bank_reg_accno_search_hash  text(2147483647), 
        bank_accno_search_hash      text(2147483647), 
        agreement_completion_method text(2147483647), 
        use_electronic_invoicing bool DEFAULT FALSE NOT NULL, 
        credit_card_type int4, 
        last_modified int8, 
        enable_card_on_file bool DEFAULT FALSE NOT NULL, 
        name VARCHAR(100), 
        billing_address_id int4, 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT payment_agr_to_creditor_fk FOREIGN KEY (clearinghouse, creditor_id) REFERENCES 
        "exerp"."clearinghouse_creditors" ("clearinghouse", "creditor_id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT payment_agr_to_acc_fk FOREIGN KEY (center, id) REFERENCES "exerp"."payment_accounts" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT pagr_to_current_pagr_fk FOREIGN KEY (current_center, current_id, current_subid) 
    REFERENCES "exerp"."payment_agreements" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT payment_agr_to_payment_agr_fk FOREIGN KEY (prev_center, prev_id, prev_subid) 
    REFERENCES "exerp"."payment_agreements" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT pagr_to_poad_fk FOREIGN KEY (billing_address_id) REFERENCES "exerp"."postal_address" 
    ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
