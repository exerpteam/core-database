CREATE TABLE 
    task_activity 
    ( 
        id int4 NOT NULL, 
        status text(2147483647) NOT NULL, 
        workflow_id int4, 
        name text(2147483647) NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT activity_to_workflow_fk FOREIGN KEY (workflow_id) REFERENCES "exerp"."workflows" 
        ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
