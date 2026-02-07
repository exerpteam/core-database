# task_actions_requirements
Task-oriented table supporting workflow execution for task actions requirements. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `task_action_id` | Foreign key field linking this record to `task_actions`. | `int4` | No | Yes | [task_actions](task_actions.md) via (`task_action_id` -> `id`) | - | `1001` |
| `requirement_type` | Text field containing descriptive or reference information. | `VARCHAR(100)` | No | Yes | - | - | `Sample value` |
| `mime_value` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |

# Relations
- FK-linked tables: outgoing FK to [task_actions](task_actions.md).
- Second-level FK neighborhood includes: [task_log](task_log.md), [task_step_transitions](task_step_transitions.md), [workflows](workflows.md).
