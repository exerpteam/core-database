CREATE TABLE 
    installment_plans 
    ( 
        id int4 NOT NULL, 
        ip_config_id int4 NOT NULL, 
        person_center int4, 
        person_id int4, 
        amount NUMERIC(0,0) NOT NULL, 
        creation_time int8 NOT NULL, 
        installements_count int4 NOT NULL, 
        end_date DATE NOT NULL, 
        employee_center int4, 
        employee_id int4, 
        version int8, 
        collect_agreement_center int4, 
        collect_agreement_id int4, 
        collect_agreement_subid int4, 
        name VARCHAR(300), 
        last_modified int8, 
        single_booking_date DATE, 
        PRIMARY KEY (id), 
        CONSTRAINT ip_employee_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ip_ipconfig_fk FOREIGN KEY (ip_config_id) REFERENCES 
    "exerp"."installment_plan_configs" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ip_person_fk FOREIGN KEY (person_center, person_id) REFERENCES "exerp"."persons" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
