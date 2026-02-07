select 
    e.id,
    event_type_id,
    e.scope_type,
    e.scope_id,
    state,
    action_type,
    e.name,
    push_template_id,
   
    asynchronous,
    batch_job,
    to_timestamp(last_changed_date / 1000) as last_changed_date,
    t.description, 
    t.scope_id,

    push_message_target_id,
    pt.name,
    pt.url,
    pt.target_type

from event_type_config e
left join templates t
on e.push_template_id = t.id
left join push_message_targets pt
on e.push_message_target_id = pt.id