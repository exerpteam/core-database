CREATE TABLE 
    cashcollection_requests 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        STATE int4 NOT NULL, 
        REF        text(2147483647), 
        req_amount NUMERIC(0,0) NOT NULL, 
        req_date   DATE NOT NULL, 
        req_delivery int4, 
        file_out int4, 
        xfr_delivery int4, 
        payment_request_center int4, 
        payment_request_id int4, 
        payment_request_subid int4, 
        prscenter int4, 
        prsid int4, 
        prssubid int4, 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT ccolreq_to_ccolin_fk FOREIGN KEY (xfr_delivery) REFERENCES 
        "exerp"."cashcollection_in" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ccolreq_to_cccase_acc_fk FOREIGN KEY (center, id) REFERENCES 
    "exerp"."cashcollectioncases" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ccr_file_out_fk FOREIGN KEY (file_out) REFERENCES "exerp"."exchanged_file" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ccr_to_prs_fk FOREIGN KEY (prscenter, prsid, prssubid) REFERENCES 
    "exerp"."payment_request_specifications" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
