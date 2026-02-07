CREATE TABLE 
    task_user_choices 
    ( 
        id int4 NOT NULL, 
        workflow_id int4, 
        status      text(2147483647) NOT NULL, 
        name        text(2147483647) NOT NULL, 
        description text(2147483647), 
        requires_text bool DEFAULT FALSE NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT lostreason_to_workflow_fk FOREIGN KEY (workflow_id) REFERENCES 
        "exerp"."workflows" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
