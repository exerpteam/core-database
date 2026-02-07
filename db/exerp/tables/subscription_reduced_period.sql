CREATE TABLE 
    subscription_reduced_period 
    ( 
        id int4 NOT NULL, 
        freeze_period int4, 
        main_reduced_period int4, 
        subscription_center int4, 
        subscription_id int4, 
        start_date DATE NOT NULL, 
        end_date   DATE NOT NULL, 
        type       text(2147483647) NOT NULL, 
        STATE      text(2147483647) NOT NULL, 
        entry_time int8 NOT NULL, 
        cancel_time int8, 
        text text(2147483647), 
        employee_center int4, 
        employee_id int4, 
        cancel_employee_center int4, 
        cancel_employee_id int4, 
        last_modified int8, 
        PRIMARY KEY (id), 
        CONSTRAINT srp_c_emp_fk FOREIGN KEY (cancel_employee_center, cancel_employee_id) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT srp_emp_fk FOREIGN KEY (employee_center, employee_id) REFERENCES "exerp"."employees" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT srp_freeze_period_fk FOREIGN KEY (freeze_period) REFERENCES 
    "exerp"."subscription_freeze_period" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT srp_main_reduced_period_fk FOREIGN KEY (main_reduced_period) REFERENCES 
    "exerp"."subscription_reduced_period" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT srp_sub_fk FOREIGN KEY (subscription_center, subscription_id) REFERENCES 
    "exerp"."subscriptions" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
