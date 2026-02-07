CREATE TABLE 
    kpi_fields 
    ( 
        id int4 NOT NULL, 
        name         text(2147483647) NOT NULL, 
        KEY          text(2147483647) NOT NULL, 
        external_id  text(2147483647), 
        type         text(2147483647) NOT NULL, 
        display_type text(2147483647) NOT NULL, 
        display_decimals int4 DEFAULT 0 NOT NULL, 
        start_date DATE NOT NULL, 
        configuration bytea, 
        last_calculation DATE, 
        STATE            text(2147483647) NOT NULL, 
        description      text(2147483647), 
        scope_type       text(2147483647), 
        scope_id int4, 
        kpi bool DEFAULT FALSE NOT NULL, 
        best_rate text(2147483647), 
        recalculate_from_dependent bool DEFAULT FALSE NOT NULL, 
        scope_aggregation text(2147483647), 
        time_aggregation  text(2147483647), 
        dashboard bool, 
        dashboard_scale_from NUMERIC(0,0), 
        dashboard_scale_to   NUMERIC(0,0), 
        dashboard_target_fieldid int4, 
        benchmark bool, 
        benchmark_interval_type text(2147483647), 
        benchmark_scope         text(2147483647), 
        live bool, 
        dashboard_warning_percentage int4 DEFAULT 0 NOT NULL, 
        refresh_interval text(2147483647) DEFAULT 'EVERY_HOUR'::text NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT kpif_to_kpif_db_target_fk FOREIGN KEY (dashboard_target_fieldid) REFERENCES 
        "exerp"."kpi_fields" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
