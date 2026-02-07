CREATE TABLE 
    privilege_receiver_groups 
    ( 
        id int4 NOT NULL, 
        rgtype     text(2147483647) DEFAULT 'CAMPAIGN'::text NOT NULL, 
        scope_type text(2147483647), 
        scope_id int4, 
        blocked bool DEFAULT FALSE NOT NULL, 
        name        text(2147483647) NOT NULL, 
        plugin_name text(2147483647), 
        plugin_config bytea, 
        starttime int8, 
        endtime int8, 
        web_text          text(2147483647), 
        available_scopes  text(2147483647), 
        plugin_codes_name text(2147483647), 
        plugin_codes_config bytea, 
        free_text text(2147483647), 
        creation_time int8, 
        creator_id int4, 
        creator_center int4, 
        last_modified int8, 
        last_editor_id int4, 
        last_editor_center int4, 
        PRIMARY KEY (id) 
    );
