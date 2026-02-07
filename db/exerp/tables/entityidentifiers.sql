CREATE TABLE 
    entityidentifiers 
    ( 
        id int4 NOT NULL, 
        idmethod int4 NOT NULL, 
        IDENTITY text(2147483647) NOT NULL, 
        cached int8, 
        ref_type int4 NOT NULL, 
        ref_center int4, 
        ref_id int4, 
        ref_globalid text(2147483647), 
        entitystatus int4 NOT NULL, 
        scope_type text(2147483647), 
        scope_id int4, 
        start_time int8 NOT NULL, 
        stop_time int8, 
        invoiceline_center int4, 
        invoiceline_id int4, 
        invoiceline_subid int4, 
        assign_employee_center int4, 
        assign_employee_id int4, 
        block_employee_center int4, 
        block_employee_id int4, 
        sub_idmethod int4, 
        source_type text(2147483647) DEFAULT 'REGULAR'::text, 
        quantity int4, 
        last_modified int8, 
        PRIMARY KEY (id) 
    );
