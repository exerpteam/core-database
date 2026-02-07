CREATE TABLE 
    template_signatures 
    ( 
        id int4 NOT NULL, 
        template_id int4 NOT NULL, 
        name text(2147483647) NOT NULL, 
        reason int4 NOT NULL, 
        rank int4 NOT NULL, 
        position_left NUMERIC(0,0), 
        position_top  NUMERIC(0,0), 
        width         NUMERIC(0,0), 
        height        NUMERIC(0,0), 
        page int4, 
        PRIMARY KEY (id) 
    );
