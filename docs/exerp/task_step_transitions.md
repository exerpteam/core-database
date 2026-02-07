# task_step_transitions
Task-oriented table supporting workflow execution for task step transitions. It is typically used where it appears in approximately 2 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `task_action_id` | Identifier of the related task actions record used by this row. | `int4` | Yes | No | [task_actions](task_actions.md) via (`task_action_id` -> `id`) | - |
| `task_step_id` | Identifier of the related task steps record used by this row. | `int4` | Yes | No | [task_steps](task_steps.md) via (`task_step_id` -> `id`) | - |
| `transition_to_step_id` | Identifier of the related task steps record used by this row. | `int4` | Yes | No | [task_steps](task_steps.md) via (`transition_to_step_id` -> `id`) | - |
| `task_user_choice_id` | Identifier for the related task user choice entity used by this record. | `int4` | Yes | No | - | [task_user_choices](task_user_choices.md) via (`task_user_choice_id` -> `id`) |
| `new_task_status` | State indicator used to control lifecycle transitions and filtering. | `text(2147483647)` | Yes | No | - | - |
| `assign_category_id` | Identifier for the related assign category entity used by this record. | `int4` | Yes | No | - | - |
| `post_transition_action` | Business attribute `post_transition_action` used by task step transitions workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `follow_up_interval_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `follow_up_interval` | Business attribute `follow_up_interval` used by task step transitions workflows and reporting. | `int4` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [task_actions](task_actions.md), [task_steps](task_steps.md).
- Second-level FK neighborhood includes: [progress](progress.md), [task_actions_requirements](task_actions_requirements.md), [task_log](task_log.md), [tasks](tasks.md), [workflows](workflows.md).
