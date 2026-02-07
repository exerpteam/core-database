CREATE TABLE 
    card_clip_usages 
    ( 
        id int4 NOT NULL, 
        TIME int8 DEFAULT 0 NOT NULL, 
        employee_center int4, 
        employee_id int4, 
        description text(2147483647) NOT NULL, 
        type        text(2147483647) NOT NULL, 
        STATE       text(2147483647) NOT NULL, 
        clips int4 NOT NULL, 
        REF int4, 
        card_center int4, 
        card_id int4, 
        card_subid int4, 
        clipcard_usage_commission int4, 
        cancellation_timestamp int8, 
        last_modified int8, 
        activation_timestamp int8, 
        creditline_center int4, 
        creditline_id int4, 
        creditline_subid int4, 
        PRIMARY KEY (id), 
        CONSTRAINT usages_to_card_fk FOREIGN KEY (card_center, card_id, card_subid) REFERENCES 
        "exerp"."clipcards" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ccu_to_creditline_fk FOREIGN KEY (creditline_center, creditline_id, creditline_subid 
    ) REFERENCES "exerp"."credit_note_lines_mt" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ccu_to_employee_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
    "exerp"."employees" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
