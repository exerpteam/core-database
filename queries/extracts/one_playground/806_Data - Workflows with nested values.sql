WITH wf AS (
    SELECT
        w.id,
        w.name,
        w.status,
        w.initial_step_id,
        w.default_category_id,
        w.extended_attributes,
        w.task_title_subjects
    FROM workflows AS w
),

-- Section 1: GLOBAL (one row per workflow)
global_rows AS (
    SELECT
        w.name AS workflow_name,
        w.status AS workflow_status,
        'GLOBAL'::text AS workflow_section,
        'GLOBAL'::text AS workflow_section_name,
        w.status AS workflow_section_status,
        (
            SELECT jsonb_object_agg(k, v ORDER BY k)
            FROM (VALUES
                ('name', to_jsonb(w.name)),
                ('task_title_subjects', to_jsonb(w.task_title_subjects)),
                ('initial_step_name', to_jsonb(istep.name)),
                ('default_category_name', to_jsonb(defcat.name))
            ) AS kv(k, v)
        )::jsonb::text AS value
    FROM wf AS w
    LEFT JOIN task_steps AS istep ON istep.id = w.initial_step_id
    LEFT JOIN task_categories AS defcat ON defcat.id = w.default_category_id
),

-- Section 2: TASK_STEP (all steps for each workflow)
task_step_rows AS (
    SELECT
        w.name AS workflow_name,
        w.status AS workflow_status,
        'TASK_STEP'::text AS workflow_section,
        ts.name AS workflow_section_name,
        ts.status AS workflow_section_status,
        (
            SELECT jsonb_object_agg(k, v ORDER BY k)
            FROM (VALUES
                ('name', to_jsonb(ts.name)),
                ('description', to_jsonb(ts.description)),
                ('task_activity_name', to_jsonb(ta.name))
            ) AS kv(k, v)
        )::jsonb::text AS value
    FROM task_steps AS ts
    JOIN wf AS w ON w.id = ts.workflow_id
    LEFT JOIN task_activity AS ta ON ta.id = ts.task_activity_id
),

-- Section 3a: Pre-process task action requirements to decode user choices from XML
task_requirement_user_choices AS (
    WITH base AS (
        SELECT
            task_action_id,
            requirement_type,
            -- Only decode for USER_CHOICE type, others might not be valid UTF8
            CASE
                WHEN requirement_type = 'USER_CHOICE' THEN convert_from(mime_value, 'UTF8')
                ELSE NULL
            END AS decoded_value
        FROM task_actions_requirements
    ),
    xml_parsed AS (
        SELECT
            task_action_id,
            requirement_type,
            (xpath('/configuration/value/text/text()', decoded_value::xml))[1]::text AS user_choice_ids_text
        FROM base
        WHERE decoded_value IS NOT NULL
    ),
    split_choices AS (
        SELECT
            task_action_id,
            requirement_type,
            -- Unnest can produce no rows if the string is empty/null, which is fine.
            unnest(string_to_array(user_choice_ids_text, ','))::integer AS user_choice_id
        FROM xml_parsed
        WHERE user_choice_ids_text IS NOT NULL AND user_choice_ids_text != ''
    )
    SELECT
        sc.task_action_id,
        sc.requirement_type,
        jsonb_agg(tuc.name ORDER BY tuc.name) as user_choices_names
    FROM split_choices AS sc
    JOIN task_user_choices AS tuc ON tuc.id = sc.user_choice_id
    GROUP BY sc.task_action_id, sc.requirement_type
),

-- Section 3: TASK_ACTION (all actions for each workflow; requirements are ordered deterministically)
task_action_rows AS (
    SELECT
        w.name AS workflow_name,
        w.status AS workflow_status,
        'TASK_ACTION'::text AS workflow_section,
        a.name AS workflow_section_name,
        a.status AS workflow_section_status,
        (
            SELECT jsonb_object_agg(k, v ORDER BY k)
            FROM (VALUES
                ('name', to_jsonb(a.name)),
                ('automatic', to_jsonb(a.automatic)),
                ('requirements',
                    COALESCE(
                        (
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'requirement_type', r.requirement_type,
                                    'value',
                                    CASE
                                        WHEN r.requirement_type = 'USER_CHOICE' THEN COALESCE(uc.user_choices_names, '[]'::jsonb)
                                        ELSE to_jsonb(r.mime_value)
                                    END
                                )
                                ORDER BY r.requirement_type
                            )
                            FROM task_actions_requirements AS r
                            LEFT JOIN task_requirement_user_choices AS uc
                                ON r.task_action_id = uc.task_action_id
                                AND r.requirement_type = uc.requirement_type
                            WHERE r.task_action_id = a.id
                        ),
                        '[]'::jsonb
                    )
                )
            ) AS kv(k, v)
        )::jsonb::text AS value
    FROM task_actions AS a
    JOIN wf AS w ON w.id = a.workflow_id
),

-- Section 4: TRANSITION (all transitions, named key retained)
transition_rows AS (
    SELECT
        w.name AS workflow_name,
        w.status AS workflow_status,
        'TRANSITION'::text AS workflow_section,
        ('FROM: '||from_ts.name||' | ACTION: '||act.name||' | CHOICE: '||
            COALESCE(uc.name,'NONE')||' | TO: '||to_ts.name) AS workflow_section_name,
        'NOT-APPLICABLE'::text AS workflow_section_status,
        (
            SELECT jsonb_object_agg(k, v ORDER BY k)
            FROM (VALUES
                ('from_step_name', to_jsonb(from_ts.name)),
                ('action_name', to_jsonb(act.name)),
                ('user_choice_name', to_jsonb(uc.name)),
                ('to_step_name', to_jsonb(to_ts.name)),
                ('new_task_status', to_jsonb(t.new_task_status)),
                ('category_name', to_jsonb(cat.name)),
                ('follow_up_interval_type',to_jsonb(t.follow_up_interval_type)),
                ('follow_up_interval', to_jsonb(t.follow_up_interval)),
                ('post_transition_action', to_jsonb(t.post_transition_action))
            ) AS kv(k, v)
        )::jsonb::text AS value
    FROM task_step_transitions AS t
    JOIN task_actions AS act ON act.id = t.task_action_id
    JOIN wf AS w ON w.id = act.workflow_id
    JOIN task_steps AS from_ts ON from_ts.id = t.task_step_id
    JOIN task_steps AS to_ts ON to_ts.id = t.transition_to_step_id
    LEFT JOIN task_user_choices AS uc ON uc.id = t.task_user_choice_id
    LEFT JOIN task_categories AS cat ON cat.id = t.assign_category_id
),

-- Section 5: USER_CHOICE (all choices)
user_choice_rows AS (
    SELECT
        w.name AS workflow_name,
        w.status AS workflow_status,
        'USER_CHOICE'::text AS workflow_section,
        c.name AS workflow_section_name,
        c.status AS workflow_section_status,
        (
            SELECT jsonb_object_agg(k, v ORDER BY k)
            FROM (VALUES
                ('name', to_jsonb(c.name)),
                ('requires_text', to_jsonb(c.requires_text)),
                ('description', to_jsonb(c.description))
            ) AS kv(k, v)
        )::jsonb::text AS value
    FROM task_user_choices AS c
    JOIN wf AS w ON w.id = c.workflow_id
),

-- Section 6: TASK_CATEGORY (all categories)
task_category_rows AS (
    SELECT
        w.name AS workflow_name,
        w.status AS workflow_status,
        'TASK_CATEGORY'::text AS workflow_section,
        cat.name AS workflow_section_name,
        cat.status AS workflow_section_status,
        (
            SELECT jsonb_object_agg(k, v ORDER BY k)
            FROM (VALUES
                ('name', to_jsonb(cat.name)),
                ('description', to_jsonb(cat.description)),
                ('color', to_jsonb(cat.color))
            ) AS kv(k, v)
        )::jsonb::text AS value
    FROM task_categories AS cat
    JOIN wf AS w ON w.id = cat.workflow_id
),

-- Section 7: TASK_ACTIVITY (all activities)
task_activity_rows AS (
    SELECT
        w.name AS workflow_name,
        w.status AS workflow_status,
        'TASK_ACTIVITY'::text AS workflow_section,
        a.name AS workflow_section_name,
        a.status AS workflow_section_status,
        (
            SELECT jsonb_object_agg(k, v ORDER BY k)
            FROM (VALUES
                ('name', to_jsonb(a.name))
            ) AS kv(k, v)
        )::jsonb::text AS value
    FROM task_activity AS a
    JOIN wf AS w ON w.id = a.workflow_id
),

-- Section 8: EXTENDED_ATTRIBUTE (one row per workflow; keep the original array/object intact)
extended_attribute_rows AS (
    SELECT
        w.name AS workflow_name,
        w.status AS workflow_status,
        'EXTENDED_ATTRIBUTE'::text AS workflow_section,
        'ATTRIBUTES'::text AS workflow_section_name,
        'NOT-APPLICABLE'::text AS workflow_section_status,
        (
            SELECT jsonb_object_agg(k, v ORDER BY k)
            FROM (VALUES
                ('attributes', w.extended_attributes)
            ) AS kv(k, v)
        )::jsonb::text AS value
    FROM wf AS w
)

-- Final Selection: Union all sections together
SELECT * FROM global_rows
UNION ALL SELECT * FROM task_step_rows
UNION ALL SELECT * FROM task_action_rows
UNION ALL SELECT * FROM transition_rows
UNION ALL SELECT * FROM user_choice_rows
UNION ALL SELECT * FROM task_category_rows
UNION ALL SELECT * FROM task_activity_rows
UNION ALL SELECT * FROM extended_attribute_rows
ORDER BY workflow_name, workflow_status, workflow_section, workflow_section_name, workflow_section_status;
