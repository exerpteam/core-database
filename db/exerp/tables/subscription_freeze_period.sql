CREATE TABLE 
    subscription_freeze_period 
    ( 
        id int4 NOT NULL, 
        subscription_center int4, 
        subscription_id int4, 
        start_invoice_line_center int4, 
        start_invoice_line_id int4, 
        start_invoice_line_subid int4, 
        start_date DATE NOT NULL, 
        end_date   DATE NOT NULL, 
        type       text(2147483647) NOT NULL, 
        STATE      text(2147483647) NOT NULL, 
        entry_time int8 NOT NULL, 
        cancel_time int8, 
        text text(2147483647), 
        employee_center int4, 
        employee_id int4, 
        entry_interface_type int4, 
        cancel_employee_center int4, 
        cancel_employee_id int4, 
        cancel_interface_type int4, 
        end_notified bool DEFAULT TRUE NOT NULL, 
        last_modified int8, 
        PRIMARY KEY (id), 
        CONSTRAINT sfp_c_emp_fk FOREIGN KEY (cancel_employee_center, cancel_employee_id) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sfp_emp_fk FOREIGN KEY (employee_center, employee_id) REFERENCES "exerp"."employees" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sfp_start_inv_line_fk FOREIGN KEY (start_invoice_line_center, start_invoice_line_id, 
    start_invoice_line_subid) REFERENCES "exerp"."invoice_lines_mt" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sfp_sub_fk FOREIGN KEY (subscription_center, subscription_id) REFERENCES 
    "exerp"."subscriptions" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
