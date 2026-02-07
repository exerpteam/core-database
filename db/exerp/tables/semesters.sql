CREATE TABLE 
    semesters 
    ( 
        id int4 NOT NULL, 
        top_node_id int4, 
        scope_type VARCHAR(1) NOT NULL, 
        scope_id int4 NOT NULL, 
        name       VARCHAR(50), 
        start_date DATE, 
        end_date   DATE, 
        STATE      VARCHAR(10) NOT NULL, 
        available_on_web bool, 
        PRIMARY KEY (id) 
    );
