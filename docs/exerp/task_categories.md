# task_categories
Task-oriented table supporting workflow execution for task categories. It is typically used where lifecycle state codes are present; it appears in approximately 22 query files; common companions include [tasks](tasks.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | No | No | - | - | `1` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | No | No | - | - | `EXT-1001` |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `workflow_id` | Foreign key field linking this record to `workflows`. | `int4` | No | No | [workflows](workflows.md) via (`workflow_id` -> `id`) | - | `1001` |
| `color` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |

# Relations
- Commonly used with: [tasks](tasks.md) (21 query files), [persons](persons.md) (20 query files), [centers](centers.md) (19 query files), [task_steps](task_steps.md) (12 query files), [task_log](task_log.md) (8 query files), [task_actions](task_actions.md) (8 query files).
- FK-linked tables: outgoing FK to [workflows](workflows.md); incoming FK from [tasks](tasks.md).
- Second-level FK neighborhood includes: [persons](persons.md), [progress](progress.md), [task_actions](task_actions.md), [task_activity](task_activity.md), [task_log](task_log.md), [task_steps](task_steps.md), [task_types](task_types.md), [task_user_choices](task_user_choices.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
