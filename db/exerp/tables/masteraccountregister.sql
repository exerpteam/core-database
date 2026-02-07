CREATE TABLE 
    masteraccountregister 
    ( 
        id int4 NOT NULL, 
        globalid   text(2147483647) NOT NULL, 
        scope_type text(2147483647), 
        scope_id int4, 
        atype int4 NOT NULL, 
        name        text(2147483647) NOT NULL, 
        vattype     text(2147483647), 
        external_id text(2147483647), 
        definition bool DEFAULT TRUE NOT NULL, 
        available bool DEFAULT TRUE NOT NULL, 
        trans_rebook_rule_type text(2147483647), 
        trans_rebook_configuration bytea, 
        PRIMARY KEY (id) 
    );
