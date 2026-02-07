CREATE TABLE 
    cashregistertransactions 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        crttype int4 NOT NULL, 
        transtime int8 NOT NULL, 
        employeecenter int4 NOT NULL, 
        employeeid int4 NOT NULL, 
        crcenter int4, 
        crid int4, 
        crsubid int4, 
        gltranscenter int4, 
        gltransid int4, 
        gltranssubid int4, 
        artranscenter int4, 
        artransid int4, 
        artranssubid int4, 
        aptranscenter int4, 
        aptransid int4, 
        aptranssubid int4, 
        billcenter int4, 
        billid int4, 
        paysessionid int4 NOT NULL, 
        coment text(2147483647), 
        amount NUMERIC(0,0), 
        customercenter int4, 
        customerid int4, 
        cr_action text(2147483647), 
        config_payment_method_id int4, 
        marker text(2147483647), 
        installment_plan_id int4, 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT cashregtrans_to_acctrans_fk FOREIGN KEY (gltranscenter, gltransid, gltranssubid) 
        REFERENCES "exerp"."account_trans" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cashregtrans_to_artrans_fk FOREIGN KEY (artranscenter, artransid, artranssubid) 
    REFERENCES "exerp"."ar_trans" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cashregtrans_to_bill_fk FOREIGN KEY (billcenter, billid) REFERENCES "exerp"."bills" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cashregtrans_to_cashreps_fk FOREIGN KEY (crcenter, crid, crsubid) REFERENCES 
    "exerp"."cashregisterreports" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cashregtrans_to_cashregs_fk FOREIGN KEY (center, id) REFERENCES 
    "exerp"."cashregisters" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cashregtrans_to_emps_fk FOREIGN KEY (employeecenter, employeeid) REFERENCES 
    "exerp"."employees" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT cashregtrans_to_ip_fk FOREIGN KEY (installment_plan_id) REFERENCES 
    "exerp"."installment_plans" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
