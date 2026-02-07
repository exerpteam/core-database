CREATE TABLE 
    subscription_addon 
    ( 
        id int4 NOT NULL, 
        subscription_center int4, 
        subscription_id int4, 
        addon_product_id int4, 
        center_id int4, 
        start_date DATE NOT NULL, 
        end_date   DATE, 
        creation_time int8, 
        ending_time int8, 
        employee_creator_center int4, 
        employee_creator_id int4, 
        cancelled bool DEFAULT FALSE NOT NULL, 
        quantity int4 DEFAULT 1, 
        use_individual_price bool DEFAULT FALSE NOT NULL, 
        individual_price_per_unit NUMERIC(0,0), 
        binding_end_date          DATE, 
        sales_center_id int4, 
        sales_interface int4, 
        period_commission int4, 
        last_modified int8, 
        PRIMARY KEY (id), 
        CONSTRAINT sao_to_aop_fk FOREIGN KEY (addon_product_id) REFERENCES 
        "exerp"."add_on_product_definition" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sao_to_sub_fk FOREIGN KEY (subscription_center, subscription_id) REFERENCES 
    "exerp"."subscriptions" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
