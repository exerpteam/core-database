CREATE TABLE 
    sales_tax_configuration 
    ( 
        id int4 NOT NULL, 
        global_id  text(2147483647) NOT NULL, 
        name       text(2147483647) NOT NULL, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        blocked bool NOT NULL, 
        PRIMARY KEY (id) 
    );
