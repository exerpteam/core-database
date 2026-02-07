CREATE TABLE 
    bank_account_blocks 
    ( 
        id int4 NOT NULL, 
        clearing_house_id int4 NOT NULL, 
        creditor_id text(2147483647) NOT NULL, 
        created_at int8 NOT NULL, 
        created_by_center int4 NOT NULL, 
        created_by_id int4 NOT NULL, 
        reason              text(2147483647) NOT NULL, 
        bank_account_holder text(2147483647), 
        bank_regno          text(2147483647), 
        bank_branch_no      text(2147483647), 
        bank_name           text(2147483647), 
        bank_accno          text(2147483647), 
        bank_control_digits text(2147483647), 
        iban                text(2147483647), 
        bic                 text(2147483647), 
        deleted_at int8, 
        deleted_by_center int4, 
        deleted_by_id int4, 
        version int8, 
        PRIMARY KEY (id), 
        CONSTRAINT fk_bab_created_to_employees FOREIGN KEY (created_by_center, created_by_id) 
        REFERENCES "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT fk_bab_deleted_to_employees FOREIGN KEY (deleted_by_center, deleted_by_id) 
    REFERENCES "exerp"."employees" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
