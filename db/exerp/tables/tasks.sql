CREATE TABLE 
    tasks 
    ( 
        id int4 NOT NULL, 
        status text(2147483647) NOT NULL, 
        step_id int4, 
        title       text(2147483647), 
        source_type text(2147483647) NOT NULL, 
        person_center int4 NOT NULL, 
        person_id int4 NOT NULL, 
        creator_center int4 NOT NULL, 
        creator_id int4 NOT NULL, 
        owner_center int4, 
        owner_id int4, 
        asignee_center int4, 
        asignee_id int4, 
        type_id int4 NOT NULL, 
        invoice_center int4, 
        invoice_id int4, 
        follow_up DATE, 
        creation_time int8, 
        last_update_time int8, 
        permanent_note text(2147483647), 
        last_choice_id int4, 
        task_category_id int4, 
        center int4 DEFAULT 0 NOT NULL, 
        follow_up_time int8, 
        PRIMARY KEY (id), 
        CONSTRAINT task_to_asignee_fk FOREIGN KEY (asignee_center, asignee_id) REFERENCES 
        "exerp"."persons" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT task_to_creator_fk FOREIGN KEY (creator_center, creator_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT task_to_invoice_fk FOREIGN KEY (invoice_center, invoice_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT task_to_owner_fk FOREIGN KEY (owner_center, owner_id) REFERENCES "exerp"."persons" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT task_to_person_fk FOREIGN KEY (person_center, person_id) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT task_to_tskcat_fk FOREIGN KEY (task_category_id) REFERENCES 
    "exerp"."task_categories" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT task_to_step_fk FOREIGN KEY (step_id) REFERENCES "exerp"."task_steps" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT task_to_type_fk FOREIGN KEY (type_id) REFERENCES "exerp"."task_types" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT task_to_lc_type FOREIGN KEY (last_choice_id) REFERENCES "exerp"."task_user_choices" 
    ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
