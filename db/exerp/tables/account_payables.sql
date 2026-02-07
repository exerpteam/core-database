CREATE TABLE 
    account_payables 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        blocked bool DEFAULT FALSE NOT NULL, 
        suppliercenter int4 NOT NULL, 
        supplierid int4 NOT NULL, 
        employeecenter int4, 
        employeeid int4, 
        credit_max NUMERIC(0,0), 
        liability_accountcenter int4, 
        liability_accountid int4, 
        external_id text(2147483647), 
        PRIMARY KEY (center, id) 
    );
