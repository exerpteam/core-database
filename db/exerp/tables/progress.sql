CREATE TABLE 
    progress 
    ( 
        id int4 NOT NULL, 
        name text(2147483647) NOT NULL, 
        workflow_id int4, 
        external_id text(2147483647) NOT NULL, 
        rank int4 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT progress_to_workflow_fk FOREIGN KEY (workflow_id) REFERENCES "exerp"."workflows" 
        ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
