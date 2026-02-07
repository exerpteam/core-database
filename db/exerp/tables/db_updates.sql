CREATE TABLE 
    db_updates 
    ( 
        customer text(2147483647) NOT NULL, 
        major int4 NOT NULL, 
        minor int4 NOT NULL, 
        revision int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        starttime int8 NOT NULL, 
        duration int4 DEFAULT 0 NOT NULL, 
        status text(2147483647) DEFAULT 'MANUAL'::text NOT NULL, 
        type   VARCHAR(10) DEFAULT 'SQL'::text NOT NULL, 
        version_id int4 NOT NULL, 
        mimetype text(2147483647), 
        mimevalue bytea, 
        PRIMARY KEY (type, major, minor, revision, id, subid), 
        CONSTRAINT fk_update_version FOREIGN KEY (version_id) REFERENCES "exerp"."db_version" ("id" 
        ) ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
