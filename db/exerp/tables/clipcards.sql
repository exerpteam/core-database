CREATE TABLE 
    clipcards 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        owner_center int4 NOT NULL, 
        owner_id int4 NOT NULL, 
        clips_left int4 NOT NULL, 
        clips_initial int4 NOT NULL, 
        finished bool DEFAULT FALSE NOT NULL, 
        cancelled bool DEFAULT FALSE NOT NULL, 
        blocked bool DEFAULT FALSE NOT NULL, 
        invoiceline_center int4, 
        invoiceline_id int4, 
        invoiceline_subid int4, 
        refmain_center int4, 
        refmain_id int4, 
        valid_from int8 DEFAULT 1 NOT NULL, 
        valid_until int8, 
        cancellation_time int8, 
        blocking_time int8, 
        overdue_since int8, 
        assigned_staff_group int4, 
        assigned_staff_center int4, 
        assigned_staff_id int4, 
        last_modified int8, 
        cc_comment text(2147483647), 
        creditline_center int4, 
        creditline_id int4, 
        creditline_subid int4, 
        transfer_from_clipcard_center int4, 
        transfer_from_clipcard_id int4, 
        transfer_from_clipcard_subid int4, 
        recurring_participation_key int4, 
        booking_program_id int4, 
        booking_program_activity_id int4, 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT ccard_to_ccardtype_fk FOREIGN KEY (center, id) REFERENCES 
        "exerp"."clipcardtypes" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT clipcard_to_invoice_line_fk FOREIGN KEY (invoiceline_center, invoiceline_id, 
    invoiceline_subid) REFERENCES "exerp"."invoice_lines_mt" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ccard_to_person_fk FOREIGN KEY (owner_center, owner_id) REFERENCES "exerp"."persons" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ccard_to_mainsub_fk FOREIGN KEY (refmain_center, refmain_id) REFERENCES 
    "exerp"."subscriptions" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
