CREATE TABLE 
    account_receivables 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        ar_type int4 NOT NULL, 
        employeecenter int4, 
        employeeid int4, 
        customercenter int4 NOT NULL, 
        customerid int4 NOT NULL, 
        debit_max NUMERIC(0,0), 
        asset_accountcenter int4, 
        asset_accountid int4, 
        external_id text(2147483647), 
        balance     NUMERIC(0,0) DEFAULT 0 NOT NULL, 
        last_entry_time int8, 
        last_trans_time int8, 
        STATE int4 DEFAULT 0 NOT NULL, 
        collected_until int8, 
        last_modified int8, 
        PRIMARY KEY (center, id), 
        CONSTRAINT ar_to_acc_asset_fk FOREIGN KEY (asset_accountcenter, asset_accountid) REFERENCES 
        "exerp"."accounts" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ar_to_employee_fk FOREIGN KEY (employeecenter, employeeid) REFERENCES 
    "exerp"."employees" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ar_to_customer_fk FOREIGN KEY (customercenter, customerid) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
