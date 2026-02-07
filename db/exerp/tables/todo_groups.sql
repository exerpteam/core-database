CREATE TABLE 
    todo_groups 
    ( 
        id int4 NOT NULL, 
        top_node_id int4, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        name        text(2147483647), 
        STATE       text(2147483647) NOT NULL, 
        comments    text(2147483647), 
        external_id text(2147483647), 
        PRIMARY KEY (id) 
    );
