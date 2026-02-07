CREATE TABLE 
    systemproperties 
    ( 
        id int4 NOT NULL, 
        globalid   text(2147483647) NOT NULL, 
        scope_type text(2147483647), 
        scope_id int4, 
        client int4, 
        txtvalue text(2147483647), 
        mimetype text(2147483647), 
        mimevalue bytea, 
        link_type text(2147483647), 
        link_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT sp_to_client_fk FOREIGN KEY (client) REFERENCES "exerp"."clients" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
