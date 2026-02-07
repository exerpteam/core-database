CREATE TABLE 
    client_performance_statistics 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        client_id int4 NOT NULL, 
        entry_time int8 NOT NULL, 
        statistic_date DATE NOT NULL, 
        statistic_hour int4 NOT NULL, 
        statistic_minute int4 NOT NULL, 
        calls_below_1s int4, 
        calls_between_1s_and_3s int4, 
        calls_between_3s_and_10s int4, 
        calls_above_10s int4, 
        number_of_errors int4, 
        totaltime_calls_below_1s int8, 
        totaltime_calls_from_1_to_3s int8, 
        totaltime_calls_from_3_to_10s int8, 
        total_time_calls_above_10s int8, 
        PRIMARY KEY (id) 
    );
