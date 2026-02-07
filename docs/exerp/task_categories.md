# task_categories
Task-oriented table supporting workflow execution for task categories. It is typically used where lifecycle state codes are present; it appears in approximately 22 query files; common companions include [tasks](tasks.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `text(2147483647)` | No | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | No | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `workflow_id` | Identifier of the related workflows record used by this row. | `int4` | No | No | [workflows](workflows.md) via (`workflow_id` -> `id`) | - |
| `color` | Business attribute `color` used by task categories workflows and reporting. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [tasks](tasks.md) (21 query files), [persons](persons.md) (20 query files), [centers](centers.md) (19 query files), [task_steps](task_steps.md) (12 query files), [task_log](task_log.md) (8 query files), [task_actions](task_actions.md) (8 query files).
- FK-linked tables: outgoing FK to [workflows](workflows.md); incoming FK from [tasks](tasks.md).
- Second-level FK neighborhood includes: [persons](persons.md), [progress](progress.md), [task_actions](task_actions.md), [task_activity](task_activity.md), [task_log](task_log.md), [task_steps](task_steps.md), [task_types](task_types.md), [task_user_choices](task_user_choices.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
