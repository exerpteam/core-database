CREATE TABLE 
    task_actions_requirements 
    ( 
        task_action_id int4 NOT NULL, 
        requirement_type VARCHAR(100) NOT NULL, 
        mime_value bytea, 
        PRIMARY KEY (task_action_id, requirement_type), 
        CONSTRAINT requirement_to_action_fk FOREIGN KEY (task_action_id) REFERENCES 
        "exerp"."task_actions" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
