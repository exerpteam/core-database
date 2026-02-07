CREATE TABLE 
    batch_executions_dependencies 
    ( 
        from_exec int4 NOT NULL, 
        to_exec int4 NOT NULL, 
        PRIMARY KEY (from_exec, to_exec), 
        CONSTRAINT from_dependency_execution_fk FOREIGN KEY (from_exec) REFERENCES 
        "exerp"."batch_executions" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    CASCADE, 
    CONSTRAINT to_dependency_execution_fk FOREIGN KEY (to_exec) REFERENCES 
    "exerp"."batch_executions" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    CASCADE 
    );
