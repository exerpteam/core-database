# task_user_choices
Task-oriented table supporting workflow execution for task user choices. It is typically used where lifecycle state codes are present; it appears in approximately 3 query files; common companions include [task_categories](task_categories.md), [workflows](workflows.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `workflow_id` | Identifier of the related workflows record used by this row. | `int4` | Yes | No | [workflows](workflows.md) via (`workflow_id` -> `id`) | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `text(2147483647)` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `requires_text` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [task_categories](task_categories.md) (2 query files), [workflows](workflows.md) (2 query files).
- FK-linked tables: outgoing FK to [workflows](workflows.md); incoming FK from [tasks](tasks.md).
- Second-level FK neighborhood includes: [persons](persons.md), [progress](progress.md), [task_actions](task_actions.md), [task_activity](task_activity.md), [task_categories](task_categories.md), [task_log](task_log.md), [task_steps](task_steps.md), [task_types](task_types.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
