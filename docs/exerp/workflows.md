# workflows
Operational table for workflows records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 18 query files; common companions include [persons](persons.md), [task_steps](task_steps.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | No | No | - | - | `1` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | No | No | - | - | `EXT-1001` |
| `initial_step_id` | Identifier of the related initial step record. | `int4` | Yes | No | - | - | `1001` |
| `default_category_id` | Identifier of the related default category record. | `int4` | Yes | No | - | - | `1001` |
| `extended_attributes` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `task_title_subjects` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |

# Relations
- Commonly used with: [persons](persons.md) (12 query files), [task_steps](task_steps.md) (12 query files), [tasks](tasks.md) (12 query files), [person_ext_attrs](person_ext_attrs.md) (9 query files), [task_types](task_types.md) (9 query files), [task_actions](task_actions.md) (6 query files).
- FK-linked tables: incoming FK from [progress](progress.md), [task_actions](task_actions.md), [task_activity](task_activity.md), [task_categories](task_categories.md), [task_steps](task_steps.md), [task_types](task_types.md), [task_user_choices](task_user_choices.md).
- Second-level FK neighborhood includes: [task_actions_requirements](task_actions_requirements.md), [task_log](task_log.md), [task_step_transitions](task_step_transitions.md), [tasks](tasks.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
