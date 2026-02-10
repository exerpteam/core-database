-- The extract is extracted from Exerp on 2026-02-08
--  
select (a.id) ::character varying (255)                                                                               as "ACTIVITY_ID",
    a.name                                                                                                                   as "NAME",
    a.state                                                                                                                 as "STATE",
    bi_decode_field ('ACTIVITY'::character varying, 'ACTIVITY_TYPE'::character varying, a.activity_type)                                              as activity_type,
    (a.activity_group_id) ::character varying (255)                                                                                             as "ACTIVITY_GROUP_ID",
    cg.name                                                                                                                                                 as "COLOR",
    case when (coalesce (a.max_participants, 0) <= 0)              then 0 else a.max_participants         end                 as "MAX_PARTICIPANTS",
    case when (coalesce (a.max_waiting_list_participants, 0) <= 0) then 0 else a.max_waiting_list_participants end                                       as "MAX_WAITING_LIST_PARTICIPANTS",
    a.external_id                                                                                                                                                 as "ACTIVITY_EXTERNAL_ID",
    (pc.access_group_id) ::character varying (255)                                                                                                                     as "ACCESS_GROUP_ID",
    a.description                                                                                                                                                          as "DESCRIPTION",
    a.time_config_id                                                                                                                                             as "TIME_CONFIGURATION_ID",
    case when (a.course_schedule_type = 0)     then 'FIXED'::text when (a.course_schedule_type = 1) then 'CONTINUOUS'::text else ''::text                 end as "COURSE_SCHEDULE_TYPE",
    case  when (a.age_group_id = '-1'::integer) then null::character varying                                                 else (a.age_group_id) ::character varying (255) end as "AGE_GROUP_ID",
    (case when (a.energy_consumption_kcal_hour = '-1'::integer) then null::integer                                           else a.energy_consumption_kcal_hour             end) ::character varying
    (255)           as "ENERGY_CONSUMPTION",
    a.last_modified as "ETS"
from ( ( (activity a
left join colour_groups cg
on  ( ( (a.colour_group_id = cg.id) and (a.colour_group_id is not null))))
left join activity_group ag
on  ( ( (a.activity_group_id = ag.id) and (a.activity_group_id is not null))))
left join participation_configurations pc
on  ( ( (a.id = pc.activity_id) and (pc.access_group_id is not null))))
where ( ( (a.state) ::text <> 'DRAFT'::text) and (a.top_node_id is null))