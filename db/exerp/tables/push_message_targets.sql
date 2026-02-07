CREATE TABLE 
    push_message_targets 
    ( 
        id int4 NOT NULL, 
        name        text(2147483647) NOT NULL, 
        url         text(2147483647) NOT NULL, 
        username    text(2147483647), 
        password    text(2147483647), 
        target_type text(2147483647), 
        use_security_header bool DEFAULT TRUE, 
        auth_url               text(2147483647), 
        auth_type              text(2147483647), 
        secret_key_name        text(2147483647), 
        secret_key             text(2147483647), 
        properties_config_type VARCHAR(200), 
        properties_config bytea, 
        PRIMARY KEY (id) 
    );
