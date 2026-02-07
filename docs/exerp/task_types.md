# task_types
Task-oriented table supporting workflow execution for task types. It is typically used where lifecycle state codes are present; it appears in approximately 20 query files; common companions include [persons](persons.md), [tasks](tasks.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `workflow_id` | Foreign key field linking this record to `workflows`. | `int4` | No | No | [workflows](workflows.md) via (`workflow_id` -> `id`) | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | No | No | - | - |
| `follow_up_interval_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `follow_up_interval` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `roles` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `manager_roles` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `unassigned_roles` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `booking_search_id` | Identifier of the related booking search record. | `int4` | Yes | No | - | - |
| `membership_sales_access` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `staff_groups` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `available_in_lead_creation` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `follow_up_overdue_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `follow_up_overdue_interval` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `task_center_selection_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `task_specific_center` | Center part of the reference to related task specific data. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (18 query files), [tasks](tasks.md) (18 query files), [centers](centers.md) (16 query files), [task_steps](task_steps.md) (13 query files), [account_receivables](account_receivables.md) (13 query files), [person_ext_attrs](person_ext_attrs.md) (11 query files).
- FK-linked tables: outgoing FK to [workflows](workflows.md); incoming FK from [tasks](tasks.md).
- Second-level FK neighborhood includes: [persons](persons.md), [progress](progress.md), [task_actions](task_actions.md), [task_activity](task_activity.md), [task_categories](task_categories.md), [task_log](task_log.md), [task_steps](task_steps.md), [task_user_choices](task_user_choices.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
