CREATE TABLE 
    task_log 
    ( 
        id int4 NOT NULL, 
        task_id int4, 
        employee_center int4, 
        employee_id int4, 
        event_time int8 NOT NULL, 
        entry_time int8 NOT NULL, 
        task_action_id int4, 
        task_step_id int4, 
        task_status text(2147483647), 
        previous_task_log_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT task_log_to_employee_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
        "exerp"."persons" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT task_log_to_task_action_fk FOREIGN KEY (task_action_id) REFERENCES 
    "exerp"."task_actions" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT task_log_to_task_step_fk FOREIGN KEY (task_step_id) REFERENCES "exerp"."task_steps" 
    ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT task_log_to_task_fk FOREIGN KEY (task_id) REFERENCES "exerp"."tasks" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
