CREATE TABLE 
    EXTRACT 
    ( 
        id int4 NOT NULL, 
        name text(2147483647) NOT NULL, 
        target_type int4 NOT NULL, 
        roleid int4, 
        sql_query_blob bytea, 
        report_name text(2147483647), 
        report bytea, 
        api_enabled bool DEFAULT FALSE NOT NULL, 
        blocked bool DEFAULT FALSE NOT NULL, 
        scope_type text(2147483647) DEFAULT 'T'::text NOT NULL, 
        scope_id int4 DEFAULT 1 NOT NULL, 
        description text(2147483647), 
        timeout int4, 
        frequent_export bool DEFAULT FALSE NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT fk_eg_role FOREIGN KEY (roleid) REFERENCES "exerp"."roles" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
