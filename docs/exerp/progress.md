# progress
Operational table for progress records in the Exerp schema. It is typically used where it appears in approximately 9 query files; common companions include [persons](persons.md), [task_steps](task_steps.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `workflow_id` | Identifier of the related workflows record used by this row. | `int4` | Yes | No | [workflows](workflows.md) via (`workflow_id` -> `id`) | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | No | No | - | - |
| `rank` | Operational field `rank` used in query filtering and reporting transformations. | `int4` | No | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (8 query files), [task_steps](task_steps.md) (7 query files), [tasks](tasks.md) (7 query files), [workflows](workflows.md) (5 query files), [person_ext_attrs](person_ext_attrs.md) (4 query files), [centers](centers.md) (2 query files).
- FK-linked tables: outgoing FK to [workflows](workflows.md); incoming FK from [task_steps](task_steps.md).
- Second-level FK neighborhood includes: [task_actions](task_actions.md), [task_activity](task_activity.md), [task_categories](task_categories.md), [task_log](task_log.md), [task_step_transitions](task_step_transitions.md), [task_types](task_types.md), [task_user_choices](task_user_choices.md), [tasks](tasks.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier.
