CREATE TABLE 
    cashregisterreports 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        starttime int8 NOT NULL, 
        reporttime int8 NOT NULL, 
        cashinitial NUMERIC(0,0) NOT NULL, 
        cashend     NUMERIC(0,0), 
        employeecenter int4 NOT NULL, 
        employeeid int4 NOT NULL, 
        sales_total NUMERIC(0,0), 
        sales_count int4, 
        credits_total NUMERIC(0,0), 
        credits_count int4, 
        control_device_id text(2147483647) DEFAULT 'null'::text, 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT cashregreps_to_emps_fk FOREIGN KEY (employeecenter, employeeid) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
