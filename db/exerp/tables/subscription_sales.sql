CREATE TABLE 
    subscription_sales 
    ( 
        id int4 NOT NULL, 
        owner_center int4 NOT NULL, 
        owner_id int4 NOT NULL, 
        owner_type int4 NOT NULL, 
        employee_center int4 NOT NULL, 
        employee_id int4 NOT NULL, 
        company_center int4, 
        company_id int4, 
        subscription_type_center int4 NOT NULL, 
        subscription_type_id int4 NOT NULL, 
        subscription_type_type int4 NOT NULL, 
        type int4 NOT NULL, 
        price_new                 NUMERIC(0,0), 
        price_new_sponsored       NUMERIC(0,0), 
        price_new_discount        NUMERIC(0,0), 
        price_initial             NUMERIC(0,0), 
        price_initial_sponsored   NUMERIC(0,0), 
        price_initial_discount    NUMERIC(0,0), 
        price_period              NUMERIC(0,0) NOT NULL, 
        price_admin_fee           NUMERIC(0,0), 
        price_admin_fee_sponsored NUMERIC(0,0), 
        price_admin_fee_discount  NUMERIC(0,0), 
        credited                  NUMERIC(0,0), 
        binding_days int4, 
        start_date DATE, 
        sales_date DATE NOT NULL, 
        end_date   DATE, 
        subscription_center int4, 
        subscription_id int4, 
        cancellation_date DATE, 
        termination_date  DATE, 
        cancellation_employee_center int4, 
        cancellation_employee_id int4, 
        price_prorata              NUMERIC(0,0), 
        price_prorata_sponsored    NUMERIC(0,0), 
        price_prorata_discount     NUMERIC(0,0), 
        contract_excluding_sponsor NUMERIC(0,0), 
        contract_including_sponsor NUMERIC(0,0), 
        contract_sponsored         NUMERIC(0,0), 
        last_modified int8, 
        signatures_completed_time int8, 
        PRIMARY KEY (id), 
        CONSTRAINT sub_sales_to_sub_center_fk FOREIGN KEY (subscription_center) REFERENCES 
        "exerp"."centers" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sub_sales_to_employee_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
    "exerp"."employees" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sub_sales_to_company_fk FOREIGN KEY (company_center, company_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sub_sales_to_person_fk FOREIGN KEY (owner_center, owner_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sub_sales_to_product_fk FOREIGN KEY (subscription_type_center, subscription_type_id) 
    REFERENCES "exerp"."products" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sub_sales_to_sub_fk FOREIGN KEY (subscription_center, subscription_id) REFERENCES 
    "exerp"."subscriptions" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sub_sales_to_subtype_fk FOREIGN KEY (subscription_type_center, subscription_type_id) 
    REFERENCES "exerp"."subscriptiontypes" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
