CREATE TABLE 
    availability_periods 
    ( 
        id int4 NOT NULL, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        name          text(2147483647) NOT NULL, 
        schedule_type text(2147483647), 
        schedule_value bytea, 
        blocked bool DEFAULT FALSE NOT NULL, 
        deleted bool DEFAULT FALSE NOT NULL, 
        availability_period_id int4, 
        PRIMARY KEY (id) 
    );
