# task_activity
Task-oriented table supporting workflow execution for task activity. It is typically used where lifecycle state codes are present; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | No | No | - | - |
| `workflow_id` | Foreign key field linking this record to `workflows`. | `int4` | Yes | No | [workflows](workflows.md) via (`workflow_id` -> `id`) | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [workflows](workflows.md).
- Second-level FK neighborhood includes: [progress](progress.md), [task_actions](task_actions.md), [task_categories](task_categories.md), [task_steps](task_steps.md), [task_types](task_types.md), [task_user_choices](task_user_choices.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
