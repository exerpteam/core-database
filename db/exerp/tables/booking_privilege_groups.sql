CREATE TABLE 
    booking_privilege_groups 
    ( 
        id int4 NOT NULL, 
        top_node_id int4, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        name  text(2147483647), 
        STATE text(2147483647) NOT NULL, 
        converted_rr_type int4, 
        frequency_restriction_count int4, 
        frequency_restriction_value int4, 
        frequency_restriction_unit int4, 
        frequency_restriction_type int4, 
        frequency_restr_include_noshow bool DEFAULT FALSE NOT NULL, 
        PRIMARY KEY (id) 
    );
