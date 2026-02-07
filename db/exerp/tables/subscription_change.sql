CREATE TABLE 
    subscription_change 
    ( 
        id int4 NOT NULL, 
        type text(2147483647) NOT NULL, 
        change_time int8 NOT NULL, 
        effect_date DATE NOT NULL, 
        cancel_time int8, 
        old_subscription_center int4 NOT NULL, 
        old_subscription_id int4 NOT NULL, 
        new_subscription_center int4, 
        new_subscription_id int4, 
        new_change_center int4, 
        new_change_id int4, 
        prev_change_center int4, 
        prev_change_id int4, 
        employee_center int4, 
        employee_id int4, 
        REFERENCE text(2147483647), 
        PRIMARY KEY (id), 
        CONSTRAINT sub_change_to_employees_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sub_change_to_new_sub_fk FOREIGN KEY (new_subscription_center, new_subscription_id) 
    REFERENCES "exerp"."subscriptions" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sub_change_to_old_sub_fk FOREIGN KEY (old_subscription_center, old_subscription_id) 
    REFERENCES "exerp"."subscriptions" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
