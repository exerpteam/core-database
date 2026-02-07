CREATE TABLE 
    event_log 
    ( 
        id int4 NOT NULL, 
        event_configuration_id int4 NOT NULL, 
        time_stamp int8 NOT NULL, 
        reference_center int4, 
        reference_id int4, 
        reference_sub_id int4, 
        reference_table text(2147483647), 
        PRIMARY KEY (id) 
    );
