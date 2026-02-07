CREATE TABLE 
    do_not_contact 
    ( 
        id int4 NOT NULL, 
        version int8, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        target        text(2147483647) NOT NULL, 
        creation_type text(2147483647) NOT NULL, 
        target_type   text(2147483647) DEFAULT 'PHONE'::text NOT NULL, 
        source        text(2147483647) NOT NULL, 
        STATE         text(2147483647) NOT NULL, 
        origin_file   text(2147483647), 
        deletion_file text(2147483647), 
        creation_date DATE, 
        deletion_date DATE, 
        creation_employee_center int4, 
        creation_employee_id int4, 
        deletion_employee_center int4, 
        deletion_employee_id int4, 
        PRIMARY KEY (id) 
    );
