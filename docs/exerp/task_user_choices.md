# task_user_choices
Task-oriented table supporting workflow execution for task user choices. It is typically used where lifecycle state codes are present; it appears in approximately 3 query files; common companions include [task_categories](task_categories.md), [workflows](workflows.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `workflow_id` | Foreign key field linking this record to `workflows`. | `int4` | Yes | No | [workflows](workflows.md) via (`workflow_id` -> `id`) | - | `1001` |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | No | No | - | - | `1` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `requires_text` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |

# Relations
- Commonly used with: [task_categories](task_categories.md) (2 query files), [workflows](workflows.md) (2 query files).
- FK-linked tables: outgoing FK to [workflows](workflows.md); incoming FK from [tasks](tasks.md).
- Second-level FK neighborhood includes: [persons](persons.md), [progress](progress.md), [task_actions](task_actions.md), [task_activity](task_activity.md), [task_categories](task_categories.md), [task_log](task_log.md), [task_steps](task_steps.md), [task_types](task_types.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
