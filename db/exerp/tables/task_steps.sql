CREATE TABLE 
    task_steps 
    ( 
        id int4 NOT NULL, 
        status text(2147483647) NOT NULL, 
        workflow_id int4, 
        name        text(2147483647) NOT NULL, 
        description text(2147483647), 
        external_id text(2147483647) NOT NULL, 
        task_activity_id int4, 
        progress_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT step_to_progress_fk FOREIGN KEY (progress_id) REFERENCES "exerp"."progress" 
        ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT step_to_workflow_fk FOREIGN KEY (workflow_id) REFERENCES "exerp"."workflows" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
