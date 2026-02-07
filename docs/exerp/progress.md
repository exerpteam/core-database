# progress
Operational table for progress records in the Exerp schema. It is typically used where it appears in approximately 9 query files; common companions include [persons](persons.md), [task_steps](task_steps.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `workflow_id` | Foreign key field linking this record to `workflows`. | `int4` | Yes | No | [workflows](workflows.md) via (`workflow_id` -> `id`) | - | `1001` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | No | No | - | - | `EXT-1001` |
| `rank` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |

# Relations
- Commonly used with: [persons](persons.md) (8 query files), [task_steps](task_steps.md) (7 query files), [tasks](tasks.md) (7 query files), [workflows](workflows.md) (5 query files), [person_ext_attrs](person_ext_attrs.md) (4 query files), [centers](centers.md) (2 query files).
- FK-linked tables: outgoing FK to [workflows](workflows.md); incoming FK from [task_steps](task_steps.md).
- Second-level FK neighborhood includes: [task_actions](task_actions.md), [task_activity](task_activity.md), [task_categories](task_categories.md), [task_log](task_log.md), [task_step_transitions](task_step_transitions.md), [task_types](task_types.md), [task_user_choices](task_user_choices.md), [tasks](tasks.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier.
