CREATE TABLE 
    workflows 
    ( 
        id int4 NOT NULL, 
        status      text(2147483647) NOT NULL, 
        name        text(2147483647) NOT NULL, 
        external_id text(2147483647) NOT NULL, 
        initial_step_id int4, 
        default_category_id int4, 
        extended_attributes text(2147483647), 
        task_title_subjects text(2147483647), 
        PRIMARY KEY (id) 
    );
