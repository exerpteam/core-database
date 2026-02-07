# task_actions_requirements
Task-oriented table supporting workflow execution for task actions requirements. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `task_action_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [task_actions](task_actions.md) via (`task_action_id` -> `id`) | - |
| `requirement_type` | Primary key component used to uniquely identify this record. | `VARCHAR(100)` | No | Yes | - | - |
| `mime_value` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [task_actions](task_actions.md).
- Second-level FK neighborhood includes: [task_log](task_log.md), [task_step_transitions](task_step_transitions.md), [workflows](workflows.md).
