# task_actions
Task-oriented table supporting workflow execution for task actions. It is typically used where lifecycle state codes are present; it appears in approximately 19 query files; common companions include [persons](persons.md), [task_log](task_log.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `text(2147483647)` | No | No | - | - |
| `workflow_id` | Identifier of the related workflows record used by this row. | `int4` | No | No | [workflows](workflows.md) via (`workflow_id` -> `id`) | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | No | No | - | - |
| `automatic` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (17 query files), [task_log](task_log.md) (17 query files), [tasks](tasks.md) (17 query files), [centers](centers.md) (13 query files), [task_log_details](task_log_details.md) (11 query files), [employees](employees.md) (9 query files).
- FK-linked tables: outgoing FK to [workflows](workflows.md); incoming FK from [task_actions_requirements](task_actions_requirements.md), [task_log](task_log.md), [task_step_transitions](task_step_transitions.md).
- Second-level FK neighborhood includes: [persons](persons.md), [progress](progress.md), [task_activity](task_activity.md), [task_categories](task_categories.md), [task_log_details](task_log_details.md), [task_steps](task_steps.md), [task_types](task_types.md), [task_user_choices](task_user_choices.md), [tasks](tasks.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
