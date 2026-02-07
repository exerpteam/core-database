CREATE TABLE 
    advance_notices 
    ( 
        id int4 NOT NULL, 
        entry_time int8 NOT NULL, 
        status                  text(2147483647) NOT NULL, 
        next_deduction_amount   NUMERIC(0,0), 
        next_deduction_date     DATE, 
        normal_deduction_amount NUMERIC(0,0), 
        source_type             text(2147483647) NOT NULL, 
        source_id int4 NOT NULL, 
        agreement_center int4 NOT NULL, 
        agreement_id int4 NOT NULL, 
        agreement_subid int4 NOT NULL, 
        employee_center int4 NOT NULL, 
        employee_id int4 NOT NULL, 
        deduction_data bytea, 
        template_data bytea, 
        s3bucket text(2147483647), 
        s3key    text(2147483647), 
        PRIMARY KEY (id), 
        CONSTRAINT adn_to_employees FOREIGN KEY (employee_center, employee_id) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT adn_to_payagreement FOREIGN KEY (agreement_center, agreement_id, agreement_subid) 
    REFERENCES "exerp"."payment_agreements" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
