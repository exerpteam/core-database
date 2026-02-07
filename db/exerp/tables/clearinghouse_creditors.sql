CREATE TABLE 
    clearinghouse_creditors 
    ( 
        clearinghouse int4 NOT NULL, 
        scope_type text(2147483647), 
        scope_id int4, 
        creditor_id VARCHAR(16) NOT NULL, 
        blocked bool DEFAULT FALSE NOT NULL, 
        STATE           text(2147483647) NOT NULL, 
        creditor_name   text(2147483647), 
        giro_account_no text(2147483647), 
        deposit_account_center int4, 
        deposit_account_id int4, 
        liability_account_center int4, 
        liability_account_id int4, 
        rejection_account_center int4, 
        rejection_account_id int4, 
        indemnity_account_center int4, 
        indemnity_account_id int4, 
        refund_account_center int4, 
        refund_account_id int4, 
        invoice_fee_account_center int4, 
        invoice_fee_account_id int4, 
        rejection_fee_account_center int4, 
        rejection_fee_account_id int4, 
        default_creditor_ch int4, 
        default_creditor_id text(2147483647), 
        disable_unplaced_payments bool DEFAULT FALSE NOT NULL, 
        field_1            text(2147483647), 
        field_2            text(2147483647), 
        field_3            text(2147483647), 
        field_4            text(2147483647), 
        field_5            text(2147483647), 
        field_6            text(2147483647), 
        reference_modifier text(2147483647), 
        web_text           text(2147483647), 
        seller_center_id int4, 
        properties_config bytea, 
        description text(2147483647), 
        field_7     VARCHAR(40), 
        field_8     VARCHAR(40), 
        field_9     VARCHAR(40), 
        field_10    VARCHAR(40), 
        PRIMARY KEY (clearinghouse, creditor_id), 
        CONSTRAINT clrhoucred_bank_to_account_fk FOREIGN KEY (deposit_account_center, 
        deposit_account_id) REFERENCES "exerp"."accounts" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT clrhoucred_inde_to_account_fk FOREIGN KEY (indemnity_account_center, 
    indemnity_account_id) REFERENCES "exerp"."accounts" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT clrhoucred_liab_to_account_fk FOREIGN KEY (liability_account_center, 
    liability_account_id) REFERENCES "exerp"."accounts" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT clrhoucred_rej_to_account_fk FOREIGN KEY (rejection_account_center, 
    rejection_account_id) REFERENCES "exerp"."accounts" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT seller_center_to_center_fk FOREIGN KEY (seller_center_id) REFERENCES 
    "exerp"."centers" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cred_to_cred_fk FOREIGN KEY (default_creditor_ch, default_creditor_id) REFERENCES 
    "exerp"."clearinghouse_creditors" ("clearinghouse", "creditor_id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT clrhousecred_to_clrhouse_fk FOREIGN KEY (clearinghouse) REFERENCES 
    "exerp"."clearinghouses" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
