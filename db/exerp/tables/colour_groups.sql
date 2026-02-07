CREATE TABLE 
    colour_groups 
    ( 
        id int4 NOT NULL, 
        top_node_id int4, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        name   text(2147483647), 
        STATE  text(2147483647) NOT NULL, 
        colour text(2147483647), 
        old_colour_code_id int4, 
        PRIMARY KEY (id) 
    );
