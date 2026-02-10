-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    event_type_config.id,
    event_type_config.event_type_id,
    event_type_config.scope_type,
    event_type_config.scope_id,
    event_type_config.event_source,
    event_type_config.event_source_service,
    event_type_config.state,
    event_type_config.action_type,
    event_type_config.name,
    event_type_config.url,
    event_type_config.push_message_target_id,
    event_type_config.push_template_id,
    event_type_config.event_filter_config,
    event_type_config.action_config,
    event_type_config.asynchronous,
    event_type_config.batch_job,
    event_type_config.last_changed_date,
    event_type_config.action_overridable_config,
    event_type_config.action_properties_mapping,
    event_type_config.event_conditions,
    event_config_push_target_fk.name as push_message_target_fk__name, -- Purpose of this is to just understand the name of the push target
    event_config_push_target_fk.url as push_message_target_fk__url, -- Purpose of this is to just understand the URL of the push target
    templates.description as templates__description -- Purpose of this is to just understand the name of the template
FROM event_type_config
LEFT JOIN push_message_targets as event_config_push_target_fk ON event_type_config.push_message_target_id = event_config_push_target_fk.id
LEFT JOIN templates ON event_type_config.push_template_id = templates.id