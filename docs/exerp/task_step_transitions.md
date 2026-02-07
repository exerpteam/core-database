# task_step_transitions
Task-oriented table supporting workflow execution for task step transitions. It is typically used where it appears in approximately 2 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `task_action_id` | Foreign key field linking this record to `task_actions`. | `int4` | Yes | No | [task_actions](task_actions.md) via (`task_action_id` -> `id`) | - | `1001` |
| `task_step_id` | Foreign key field linking this record to `task_steps`. | `int4` | Yes | No | [task_steps](task_steps.md) via (`task_step_id` -> `id`) | - | `1001` |
| `transition_to_step_id` | Foreign key field linking this record to `task_steps`. | `int4` | Yes | No | [task_steps](task_steps.md) via (`transition_to_step_id` -> `id`) | - | `1001` |
| `task_user_choice_id` | Identifier of the related task user choice record. | `int4` | Yes | No | - | [task_user_choices](task_user_choices.md) via (`task_user_choice_id` -> `id`) | `1001` |
| `new_task_status` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `assign_category_id` | Identifier of the related assign category record. | `int4` | Yes | No | - | - | `1001` |
| `post_transition_action` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `follow_up_interval_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `follow_up_interval` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |

# Relations
- FK-linked tables: outgoing FK to [task_actions](task_actions.md), [task_steps](task_steps.md).
- Second-level FK neighborhood includes: [progress](progress.md), [task_actions_requirements](task_actions_requirements.md), [task_log](task_log.md), [tasks](tasks.md), [workflows](workflows.md).
