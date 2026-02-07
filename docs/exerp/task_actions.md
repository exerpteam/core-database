# task_actions
Task-oriented table supporting workflow execution for task actions. It is typically used where lifecycle state codes are present; it appears in approximately 19 query files; common companions include [persons](persons.md), [task_log](task_log.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | No | No | - | - | `1` |
| `workflow_id` | Foreign key field linking this record to `workflows`. | `int4` | No | No | [workflows](workflows.md) via (`workflow_id` -> `id`) | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | No | No | - | - | `EXT-1001` |
| `automatic` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |

# Relations
- Commonly used with: [persons](persons.md) (17 query files), [task_log](task_log.md) (17 query files), [tasks](tasks.md) (17 query files), [centers](centers.md) (13 query files), [task_log_details](task_log_details.md) (11 query files), [employees](employees.md) (9 query files).
- FK-linked tables: outgoing FK to [workflows](workflows.md); incoming FK from [task_actions_requirements](task_actions_requirements.md), [task_log](task_log.md), [task_step_transitions](task_step_transitions.md).
- Second-level FK neighborhood includes: [persons](persons.md), [progress](progress.md), [task_activity](task_activity.md), [task_categories](task_categories.md), [task_log_details](task_log_details.md), [task_steps](task_steps.md), [task_types](task_types.md), [task_user_choices](task_user_choices.md), [tasks](tasks.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
