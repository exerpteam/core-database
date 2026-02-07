CREATE TABLE 
    change_logs 
    ( 
        id int4 NOT NULL, 
        type int4 NOT NULL, 
        service_name text(2147483647) NOT NULL, 
        entry_time int8 NOT NULL, 
        employee_center int4, 
        employee_id int4, 
        source_primary    text(2147483647), 
        source_secondary  text(2147483647), 
        text_value_before text(2147483647), 
        text_value_after  text(2147483647), 
        blob_type_before  text(2147483647), 
        blob_type_after   text(2147483647), 
        blob_value_before bytea, 
        blob_value_after bytea, 
        PRIMARY KEY (id) 
    );
