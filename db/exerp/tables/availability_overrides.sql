CREATE TABLE 
    availability_overrides 
    ( 
        id int4 NOT NULL, 
        override_date DATE NOT NULL, 
        start_time    text(2147483647), 
        stop_time     text(2147483647), 
        open_all_day bool DEFAULT FALSE NOT NULL, 
        closed_all_day bool DEFAULT FALSE NOT NULL, 
        availability_period_id int4 NOT NULL, 
        override_scope_id int4 DEFAULT 0 NOT NULL, 
        override_scope_type VARCHAR(10), 
        PRIMARY KEY (id) 
    );
