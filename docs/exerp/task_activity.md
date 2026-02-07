# task_activity
Task-oriented table supporting workflow execution for task activity. It is typically used where lifecycle state codes are present; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `text(2147483647)` | No | No | - | - |
| `workflow_id` | Identifier of the related workflows record used by this row. | `int4` | Yes | No | [workflows](workflows.md) via (`workflow_id` -> `id`) | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [workflows](workflows.md).
- Second-level FK neighborhood includes: [progress](progress.md), [task_actions](task_actions.md), [task_categories](task_categories.md), [task_steps](task_steps.md), [task_types](task_types.md), [task_user_choices](task_user_choices.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
