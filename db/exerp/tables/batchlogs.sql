CREATE TABLE 
    batchlogs 
    ( 
        id int4 NOT NULL, 
        scope_type text(2147483647), 
        scope_id int4, 
        jobname text(2147483647) NOT NULL, 
        completiontime int8 NOT NULL, 
        errors int4 NOT NULL, 
        fatalerrors int4 NOT NULL, 
        mimetype text(2147483647), 
        mimevalue bytea, 
        status int4, 
        starttime int8, 
        startdate DATE, 
        node      text(2147483647), 
        entity    text(2147483647), 
        PRIMARY KEY (id) 
    );
