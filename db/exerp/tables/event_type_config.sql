CREATE TABLE 
    event_type_config 
    ( 
        id int4 NOT NULL, 
        event_type_id int4, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        event_source         text(2147483647), 
        event_source_service text(2147483647), 
        STATE                text(2147483647) NOT NULL, 
        action_type          text(2147483647) NOT NULL, 
        name                 text(2147483647), 
        url                  text(2147483647), 
        push_message_target_id int4, 
        push_template_id int4, 
        event_filter_config bytea, 
        action_config bytea, 
        asynchronous bool DEFAULT TRUE NOT NULL, 
        batch_job bool DEFAULT FALSE NOT NULL, 
        last_changed_date int8 DEFAULT 0 NOT NULL, 
        action_overridable_config bytea, 
        action_properties_mapping bytea, 
        event_conditions bytea, 
        PRIMARY KEY (id), 
        CONSTRAINT event_config_push_target_fk FOREIGN KEY (push_message_target_id) REFERENCES 
        "exerp"."push_message_targets" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
