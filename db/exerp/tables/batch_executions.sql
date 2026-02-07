CREATE TABLE 
    batch_executions 
    ( 
        id int4 NOT NULL, 
        job_class  text(2147483647) NOT NULL, 
        scope_type text(2147483647), 
        scope_id int4, 
        entity_key text(2147483647), 
        earliest_exec_time int8 NOT NULL, 
        STATE int4, 
        start_time int8, 
        execution_date DATE NOT NULL, 
        node_id        text(2147483647), 
        rank int4 DEFAULT 10 NOT NULL, 
        PRIMARY KEY (id) 
    );
