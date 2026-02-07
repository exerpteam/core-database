CREATE TABLE 
    templates 
    ( 
        id int4 NOT NULL, 
        ttype int4 NOT NULL, 
        layout int4 NOT NULL, 
        description text(2147483647), 
        METHOD int4 NOT NULL, 
        outputmimetype text(2147483647), 
        mimetype       text(2147483647), 
        mimevalue bytea, 
        scope_type text(2147483647), 
        scope_id int4, 
        use_default bool DEFAULT FALSE NOT NULL, 
        SIGN bool DEFAULT FALSE NOT NULL, 
        PRIMARY KEY (id) 
    );
