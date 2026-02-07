CREATE TABLE 
    report_periods 
    ( 
        id int4 NOT NULL, 
        scope_type text(2147483647), 
        scope_id int4, 
        period_name text(2147483647) NOT NULL, 
        start_date  DATE, 
        end_date    DATE, 
        close_time int8 NOT NULL, 
        hard_close_time int8, 
        PRIMARY KEY (id) 
    );
