CREATE TABLE 
    task_actions 
    ( 
        id int4 NOT NULL, 
        status text(2147483647) NOT NULL, 
        workflow_id int4 NOT NULL, 
        name        text(2147483647) NOT NULL, 
        external_id text(2147483647) NOT NULL, 
        automatic bool DEFAULT FALSE NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT action_to_workflow_fk FOREIGN KEY (workflow_id) REFERENCES "exerp"."workflows" 
        ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
