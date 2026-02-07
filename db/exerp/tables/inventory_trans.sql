CREATE TABLE 
    inventory_trans 
    ( 
        id int4 NOT NULL, 
        inventory int4 NOT NULL, 
        type   text(2147483647) NOT NULL, 
        coment text(2147483647), 
        product_center int4 NOT NULL, 
        product_id int4 NOT NULL, 
        entry_time int8 NOT NULL, 
        book_time int8 NOT NULL, 
        had_report_role bool DEFAULT FALSE NOT NULL, 
        quantity int4 NOT NULL, 
        unit_value NUMERIC(0,0) NOT NULL, 
        remaining int4 NOT NULL, 
        ref_type text(2147483647), 
        ref_center int4, 
        ref_id int4, 
        ref_subid int4, 
        source_id int4, 
        first_source_id int4, 
        last_write_off_id int4, 
        employee_center int4, 
        employee_id int4, 
        balance_quantity int4 NOT NULL, 
        balance_value NUMERIC(0,0) NOT NULL, 
        account_trans_center int4, 
        account_trans_id int4, 
        account_trans_subid int4, 
        PRIMARY KEY (id), 
        CONSTRAINT it_to_at_fk FOREIGN KEY (account_trans_center, account_trans_id, 
        account_trans_subid) REFERENCES "exerp"."account_trans" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT it_to_em_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
    "exerp"."employees" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT it_to_in_fk FOREIGN KEY (inventory) REFERENCES "exerp"."inventory" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT it_to_it_fk FOREIGN KEY (source_id) REFERENCES "exerp"."inventory_trans" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT it_to_it_fs_fk FOREIGN KEY (first_source_id) REFERENCES "exerp"."inventory_trans" 
    ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT it_to_it_lwo_fk FOREIGN KEY (last_write_off_id) REFERENCES "exerp"."inventory_trans" 
    ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT it_to_pr_fk FOREIGN KEY (product_center, product_id) REFERENCES "exerp"."products" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
