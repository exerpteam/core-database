# task_steps
Task-oriented table supporting workflow execution for task steps. It is typically used where lifecycle state codes are present; it appears in approximately 44 query files; common companions include [tasks](tasks.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `text(2147483647)` | No | No | - | - |
| `workflow_id` | Identifier of the related workflows record used by this row. | `int4` | Yes | No | [workflows](workflows.md) via (`workflow_id` -> `id`) | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | No | No | - | - |
| `task_activity_id` | Identifier for the related task activity entity used by this record. | `int4` | Yes | No | - | [task_activity](task_activity.md) via (`task_activity_id` -> `id`) |
| `progress_id` | Identifier of the related progress record used by this row. | `int4` | Yes | No | [progress](progress.md) via (`progress_id` -> `id`) | - |

# Relations
- Commonly used with: [tasks](tasks.md) (42 query files), [persons](persons.md) (41 query files), [person_ext_attrs](person_ext_attrs.md) (28 query files), [centers](centers.md) (28 query files), [task_log](task_log.md) (14 query files), [task_types](task_types.md) (13 query files).
- FK-linked tables: outgoing FK to [progress](progress.md), [workflows](workflows.md); incoming FK from [task_log](task_log.md), [task_step_transitions](task_step_transitions.md), [tasks](tasks.md).
- Second-level FK neighborhood includes: [persons](persons.md), [task_actions](task_actions.md), [task_activity](task_activity.md), [task_categories](task_categories.md), [task_log_details](task_log_details.md), [task_types](task_types.md), [task_user_choices](task_user_choices.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
