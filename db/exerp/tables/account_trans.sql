CREATE TABLE 
    account_trans 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        trans_type int4 NOT NULL, 
        trans_time int8 NOT NULL, 
        entry_time int8 NOT NULL, 
        amount NUMERIC(0,0) NOT NULL, 
        debit_accountcenter int4 NOT NULL, 
        debit_accountid int4 NOT NULL, 
        credit_accountcenter int4 NOT NULL, 
        credit_accountid int4 NOT NULL, 
        main_transcenter int4, 
        main_transid int4, 
        main_transsubid int4, 
        origin_transcenter int4, 
        origin_transid int4, 
        origin_transsubid int4, 
        text text(2147483647) NOT NULL, 
        transferred bool DEFAULT FALSE NOT NULL, 
        export_file int4, 
        aggregated_transaction_center int4, 
        aggregated_transaction_id int4, 
        vat_type_center int4, 
        vat_type_id int4, 
        info_type int4 NOT NULL, 
        info text(2147483647), 
        debit_transaction_center int4, 
        debit_transaction_id int4, 
        debit_transaction_subid int4, 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT acc_trams_to_orig_acc_trans_fk FOREIGN KEY (origin_transcenter, origin_transid, 
        origin_transsubid) REFERENCES "exerp"."account_trans" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT acc_trans_to_main_acc_trans_fk FOREIGN KEY (main_transcenter, main_transid, 
    main_transsubid) REFERENCES "exerp"."account_trans" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT acc_trans_to_acc_period_fk FOREIGN KEY (center, id) REFERENCES 
    "exerp"."accountingperiods" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT acc_trans_to_cred_acc_fk FOREIGN KEY (credit_accountcenter, credit_accountid) 
    REFERENCES "exerp"."accounts" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT acc_trans_to_deb_acc_fk FOREIGN KEY (debit_accountcenter, debit_accountid) 
    REFERENCES "exerp"."accounts" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT acc_trans_to_aggr_trans_fk FOREIGN KEY (aggregated_transaction_center, 
    aggregated_transaction_id) REFERENCES "exerp"."aggregated_transactions" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT acc_trans_to_vat_type_fk FOREIGN KEY (vat_type_center, vat_type_id) REFERENCES 
    "exerp"."vat_types" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
