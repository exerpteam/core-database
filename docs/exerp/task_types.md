# task_types
Task-oriented table supporting workflow execution for task types. It is typically used where lifecycle state codes are present; it appears in approximately 20 query files; common companions include [persons](persons.md), [tasks](tasks.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `text(2147483647)` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `workflow_id` | Identifier of the related workflows record used by this row. | `int4` | No | No | [workflows](workflows.md) via (`workflow_id` -> `id`) | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | No | No | - | - |
| `follow_up_interval_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `follow_up_interval` | Business attribute `follow_up_interval` used by task types workflows and reporting. | `int4` | Yes | No | - | - |
| `roles` | Operational field `roles` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `manager_roles` | Business attribute `manager_roles` used by task types workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `unassigned_roles` | Business attribute `unassigned_roles` used by task types workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `booking_search_id` | Identifier for the related booking search entity used by this record. | `int4` | Yes | No | - | - |
| `membership_sales_access` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `staff_groups` | Operational field `staff_groups` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `available_in_lead_creation` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `follow_up_overdue_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `follow_up_overdue_interval` | Business attribute `follow_up_overdue_interval` used by task types workflows and reporting. | `int4` | Yes | No | - | - |
| `task_center_selection_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `task_specific_center` | Business attribute `task_specific_center` used by task types workflows and reporting. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (18 query files), [tasks](tasks.md) (18 query files), [centers](centers.md) (16 query files), [task_steps](task_steps.md) (13 query files), [account_receivables](account_receivables.md) (13 query files), [person_ext_attrs](person_ext_attrs.md) (11 query files).
- FK-linked tables: outgoing FK to [workflows](workflows.md); incoming FK from [tasks](tasks.md).
- Second-level FK neighborhood includes: [persons](persons.md), [progress](progress.md), [task_actions](task_actions.md), [task_activity](task_activity.md), [task_categories](task_categories.md), [task_log](task_log.md), [task_steps](task_steps.md), [task_user_choices](task_user_choices.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
