# workflows
Operational table for workflows records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 18 query files; common companions include [persons](persons.md), [task_steps](task_steps.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `text(2147483647)` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | No | No | - | - |
| `initial_step_id` | Identifier for the related initial step entity used by this record. | `int4` | Yes | No | - | - |
| `default_category_id` | Identifier for the related default category entity used by this record. | `int4` | Yes | No | - | - |
| `extended_attributes` | Business attribute `extended_attributes` used by workflows workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `task_title_subjects` | Business attribute `task_title_subjects` used by workflows workflows and reporting. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (12 query files), [task_steps](task_steps.md) (12 query files), [tasks](tasks.md) (12 query files), [person_ext_attrs](person_ext_attrs.md) (9 query files), [task_types](task_types.md) (9 query files), [task_actions](task_actions.md) (6 query files).
- FK-linked tables: incoming FK from [progress](progress.md), [task_actions](task_actions.md), [task_activity](task_activity.md), [task_categories](task_categories.md), [task_steps](task_steps.md), [task_types](task_types.md), [task_user_choices](task_user_choices.md).
- Second-level FK neighborhood includes: [task_actions_requirements](task_actions_requirements.md), [task_log](task_log.md), [task_step_transitions](task_step_transitions.md), [tasks](tasks.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
