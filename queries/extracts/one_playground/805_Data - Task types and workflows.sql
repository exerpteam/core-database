-- The extract is extracted from Exerp on 2026-02-08
--  
with cte__task_staff_group_ids as (
        SELECT
            task_types.id,
            regexp_split_to_table(task_types.staff_groups, ',')::integer as staff_group_id
        FROM task_types
        where length(task_types.staff_groups) > 0
        order by 1, 2
    ),

    cte__task_staff_group_names as (
        select
            cte__task_staff_group_ids.id,
            jsonb_agg(staff_groups.name order by staff_groups.name) as staff_group_names
        from cte__task_staff_group_ids
        left join staff_groups on cte__task_staff_group_ids.staff_group_id = staff_groups.id
        group by 1
    )

SELECT
    task_types.id as task_types__id,
    task_types.status as task_types__status,
    task_types.name as task_types__name,
    task_types.description as task_types__description,
    task_types.workflow_id as task_types__workflow_id,
    task_types.scope_type as task_types__scope_type,
    task_types.scope_id as task_types__scope_id,
    task_types.external_id as task_types__external_id,
    task_types.follow_up_interval_type as task_types__follow_up_interval_type,
    task_types.follow_up_interval as task_types__follow_up_interval,
    (SELECT jsonb_agg(val ORDER BY val) FROM (SELECT DISTINCT btrim(x) AS val FROM unnest(regexp_split_to_array(coalesce(task_types.roles,''), ',')) AS t(x) WHERE btrim(x) <> '') s) AS task_types__roles,
    (SELECT jsonb_agg(val ORDER BY val) FROM (SELECT DISTINCT btrim(x) AS val FROM unnest(regexp_split_to_array(coalesce(task_types.manager_roles,''), ',')) AS t(x) WHERE btrim(x) <> '') s) AS task_types__manager_roles,
    (SELECT jsonb_agg(val ORDER BY val) FROM (SELECT DISTINCT btrim(x) AS val FROM unnest(regexp_split_to_array(coalesce(task_types.unassigned_roles,''), ',')) AS t(x) WHERE btrim(x) <> '') s) AS task_types__unassigned_roles,
    task_types.booking_search_id as task_types__booking_search_id,
    task_types.membership_sales_access as task_types__membership_sales_access,
    -- task_types.staff_groups as task_types__staff_groups, -- Replaced by the named values
    cte__task_staff_group_names.staff_group_names as task_types__staff_group_names,
    task_types.available_in_lead_creation as task_types__available_in_lead_creation,
    task_types.follow_up_overdue_type as task_types__follow_up_overdue_type,
    task_types.follow_up_overdue_interval as task_types__follow_up_overdue_interval,
    task_types.task_center_selection_type as task_types__task_center_selection_type,
    task_types.task_specific_center as task_types__task_specific_center,
    tsktype_to_workflow_fk.id as tsktype_to_workflow_fk__id,
    tsktype_to_workflow_fk.status as tsktype_to_workflow_fk__status,
    tsktype_to_workflow_fk.name as tsktype_to_workflow_fk__name,
    tsktype_to_workflow_fk.external_id as tsktype_to_workflow_fk__external_id,
    tsktype_to_workflow_fk.initial_step_id as tsktype_to_workflow_fk__initial_step_id,
    tsktype_to_workflow_fk.default_category_id as tsktype_to_workflow_fk__default_category_id,
    tsktype_to_workflow_fk.extended_attributes as tsktype_to_workflow_fk__extended_attributes,
    tsktype_to_workflow_fk.task_title_subjects as tsktype_to_workflow_fk__task_title_subjects
FROM task_types
LEFT JOIN workflows as tsktype_to_workflow_fk ON task_types.workflow_id = tsktype_to_workflow_fk.id
LEFT JOIN cte__task_staff_group_names ON task_types.id = cte__task_staff_group_names.id
