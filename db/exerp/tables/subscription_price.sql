CREATE TABLE 
    subscription_price 
    ( 
        id int4 NOT NULL, 
        entry_time int8 NOT NULL, 
        from_date DATE NOT NULL, 
        to_date   DATE, 
        subscription_center int4 NOT NULL, 
        subscription_id int4 NOT NULL, 
        price NUMERIC(0,0) NOT NULL, 
        binding bool NOT NULL, 
        type   text(2147483647) DEFAULT 'MANUAL'::text NOT NULL, 
        coment text(2147483647), 
        notified bool NOT NULL, 
        employee_center int4, 
        employee_id int4, 
        applied bool NOT NULL, 
        cancelled bool DEFAULT FALSE NOT NULL, 
        approved bool DEFAULT FALSE NOT NULL, 
        pending bool DEFAULT FALSE NOT NULL, 
        approved_employee_center int4, 
        approved_employee_id int4, 
        approved_entry_time int8, 
        cancelled_employee_center int4, 
        cancelled_employee_id int4, 
        cancelled_entry_time int8, 
        aggregated_change_date DATE, 
        template_id int4, 
        event_config_id int4, 
        prorata_sessions int4, 
        prorata_sessions_total int4, 
        last_modified int8, 
        PRIMARY KEY (id), 
        CONSTRAINT sub_price_to_employees_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sub_price_to_old_sub_fk FOREIGN KEY (subscription_center, subscription_id) 
    REFERENCES "exerp"."subscriptions" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
