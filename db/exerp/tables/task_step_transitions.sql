CREATE TABLE 
    task_step_transitions 
    ( 
        id int4 NOT NULL, 
        task_action_id int4, 
        task_step_id int4, 
        transition_to_step_id int4, 
        task_user_choice_id int4, 
        new_task_status text(2147483647), 
        assign_category_id int4, 
        post_transition_action text(2147483647), 
        follow_up_interval_type int4, 
        follow_up_interval int4, 
        PRIMARY KEY (id), 
        CONSTRAINT step_mapping_to_action_fk FOREIGN KEY (task_action_id) REFERENCES 
        "exerp"."task_actions" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT step_mapping_to_step_fk FOREIGN KEY (task_step_id) REFERENCES "exerp"."task_steps" 
    ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT step_mapping_to_transi_step_fk FOREIGN KEY (transition_to_step_id) REFERENCES 
    "exerp"."task_steps" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
