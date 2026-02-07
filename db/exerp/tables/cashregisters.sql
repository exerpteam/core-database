CREATE TABLE 
    cashregisters 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        name text(2147483647) NOT NULL, 
        type text(2147483647) DEFAULT 'POS'::text NOT NULL, 
        cash bool DEFAULT TRUE NOT NULL, 
        STATE text(2147483647) DEFAULT 'OPEN'::text NOT NULL, 
        blocked bool DEFAULT FALSE NOT NULL, 
        cash_balance      NUMERIC(0,0), 
        control_device_id text(2147483647), 
        asset_accountcenter int4, 
        asset_accountid int4, 
        reconciliation_accountcenter int4, 
        reconciliation_accountid int4, 
        rounding_accountcenter int4, 
        rounding_accountid int4, 
        error_accountcenter int4, 
        error_accountid int4, 
        payout_accountcenter int4, 
        payout_accountid int4, 
        bank_accountcenter int4, 
        bank_accountid int4, 
        cc_asset_accountcenter int4, 
        cc_asset_accountid int4, 
        default_amount_to_leave NUMERIC(0,0), 
        cc_payment_method int4, 
        creditcardaccountid text(2147483647), 
        creditcardaccountpw text(2147483647), 
        credit_card_setup bytea, 
        inventory int4, 
        cc_external_require_trans_no bool DEFAULT FALSE NOT NULL, 
        automatic_closing_days    text(2147483647), 
        fiscalization_plugin_type VARCHAR(20), 
        fiscalization_plugin_config bytea, 
        PRIMARY KEY (center, id), 
        CONSTRAINT cashregs_to_acc_asset_fk FOREIGN KEY (asset_accountcenter, asset_accountid) 
        REFERENCES "exerp"."accounts" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cashregs_to_acc_bank_fk FOREIGN KEY (bank_accountcenter, bank_accountid) REFERENCES 
    "exerp"."accounts" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cashregs_to_acc_cc_asset_fk FOREIGN KEY (cc_asset_accountcenter, cc_asset_accountid) 
    REFERENCES "exerp"."accounts" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cashregs_to_acc_error_fk FOREIGN KEY (error_accountcenter, error_accountid) 
    REFERENCES "exerp"."accounts" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cashregs_to_acc_payout_fk FOREIGN KEY (payout_accountcenter, payout_accountid) 
    REFERENCES "exerp"."accounts" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cashregs_to_acc_recon_fk FOREIGN KEY (reconciliation_accountcenter, 
    reconciliation_accountid) REFERENCES "exerp"."accounts" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cashregs_to_acc_round_fk FOREIGN KEY (rounding_accountcenter, rounding_accountid) 
    REFERENCES "exerp"."accounts" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cashregs_to_center_fk FOREIGN KEY (center) REFERENCES "exerp"."centers" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cr_inventory_fk FOREIGN KEY (inventory) REFERENCES "exerp"."inventory" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
