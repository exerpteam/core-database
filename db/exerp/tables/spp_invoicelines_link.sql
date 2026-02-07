CREATE TABLE 
    spp_invoicelines_link 
    ( 
        invoiceline_center int4 NOT NULL, 
        invoiceline_id int4 NOT NULL, 
        invoiceline_subid int4 NOT NULL, 
        period_center int4 NOT NULL, 
        period_id int4 NOT NULL, 
        period_subid int4 NOT NULL, 
        PRIMARY KEY (invoiceline_center, invoiceline_id, invoiceline_subid), 
        CONSTRAINT spil_to_il_fk FOREIGN KEY (invoiceline_center, invoiceline_id, invoiceline_subid 
        ) REFERENCES "exerp"."invoice_lines_mt" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT spil_to_spp_fk FOREIGN KEY (period_center, period_id, period_subid) REFERENCES 
    "exerp"."subscriptionperiodparts" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
