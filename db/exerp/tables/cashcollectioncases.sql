CREATE TABLE 
    cashcollectioncases 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        personcenter int4 NOT NULL, 
        personid int4 NOT NULL, 
        ar_center int4, 
        ar_id int4, 
        closed bool DEFAULT FALSE NOT NULL, 
        successfull bool DEFAULT FALSE NOT NULL, 
        HOLD bool DEFAULT FALSE NOT NULL, 
        amount           NUMERIC(0,0), 
        cc_agency_amount NUMERIC(0,0), 
        cc_agency_update_source int4, 
        cc_agency_update_time int8, 
        cashcollectionservice int4, 
        ext_ref   text(2147483647), 
        startdate DATE NOT NULL, 
        currentstep int4 NOT NULL, 
        currentstep_type int4 NOT NULL, 
        currentstep_date DATE NOT NULL, 
        nextstep_date    DATE, 
        nextstep_type int4, 
        settings bytea, 
        missingpayment bool DEFAULT FALSE NOT NULL, 
        below_minimum_age bool DEFAULT FALSE NOT NULL, 
        last_modified int8, 
        start_datetime int8, 
        closed_datetime int8, 
        PRIMARY KEY (center, id), 
        CONSTRAINT ccases_to_ar_fk FOREIGN KEY (ar_center, ar_id) REFERENCES 
        "exerp"."account_receivables" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ccases_to_ccolsrv_fk FOREIGN KEY (cashcollectionservice) REFERENCES 
    "exerp"."cashcollectionservices" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ccases_to_person_fk FOREIGN KEY (personcenter, personid) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
