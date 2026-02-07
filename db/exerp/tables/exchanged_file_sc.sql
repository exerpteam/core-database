CREATE TABLE 
    exchanged_file_sc 
    ( 
        id int4 NOT NULL, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        name           text(2147483647) NOT NULL, 
        description    text(2147483647), 
        scope_grouping text(2147483647) NOT NULL, 
        SCHEDULE       text(2147483647) NOT NULL, 
        schedule_configuration bytea, 
        service text(2147483647) NOT NULL, 
        agency int4, 
        agency_configuration bytea, 
        store_in_database bool DEFAULT TRUE NOT NULL, 
        store_in_filesystem bool DEFAULT FALSE NOT NULL, 
        exports bytea, 
        status            text(2147483647) NOT NULL, 
        next_schedule_day DATE, 
        attempts int4, 
        filename_pattern text(2147483647), 
        file_format      text(2147483647), 
        export_as_gzip bool, 
        PRIMARY KEY (id) 
    );
