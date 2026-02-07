CREATE TABLE 
    awsdms_apply_exceptions 
    ( 
        TASK_NAME   VARCHAR(128) NOT NULL, 
        TABLE_OWNER VARCHAR(128) NOT NULL, 
        TABLE_NAME  VARCHAR(128) NOT NULL, 
        ERROR_TIME  TIMESTAMP NOT NULL, 
        STATEMENT   text(2147483647) NOT NULL, 
        ERROR       text(2147483647) NOT NULL 
    );
