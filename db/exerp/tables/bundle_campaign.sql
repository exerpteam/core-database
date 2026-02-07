CREATE TABLE 
    bundle_campaign 
    ( 
        id int4 NOT NULL, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        name  text(2147483647) NOT NULL, 
        STATE text(2147483647) NOT NULL, 
        starttime int8 NOT NULL, 
        endtime int8 NOT NULL, 
        auto_add_products bool, 
        price_modification_name   text(2147483647), 
        price_modification_amount NUMERIC(0,0), 
        price_modification_one_time bool, 
        prompt_type       text(2147483647) NOT NULL, 
        prompt_text       text(2147483647), 
        plugin_codes_name text(2147483647), 
        plugin_codes_config bytea, 
        basket_threshold NUMERIC(0,0), 
        PRIMARY KEY (id) 
    );
