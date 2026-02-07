CREATE TABLE 
    task_categories 
    ( 
        id int4 NOT NULL, 
        name        text(2147483647), 
        status      text(2147483647) NOT NULL, 
        external_id text(2147483647) NOT NULL, 
        description text(2147483647), 
        workflow_id int4 NOT NULL, 
        color text(2147483647), 
        PRIMARY KEY (id), 
        CONSTRAINT category_to_workflow_fk FOREIGN KEY (workflow_id) REFERENCES "exerp"."workflows" 
        ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
