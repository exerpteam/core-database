CREATE TABLE 
    staff_groups 
    ( 
        id int4 NOT NULL, 
        top_node_id int4, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        name           text(2147483647), 
        STATE          text(2147483647) NOT NULL, 
        default_salary NUMERIC(0,0), 
        old_activity_type_id int4, 
        external_reference VARCHAR(50), 
        commissionable bool DEFAULT FALSE NOT NULL, 
        PRIMARY KEY (id) 
    );
