# task_log_details
Stores historical/log records for task details events and changes. It is typically used where it appears in approximately 23 query files; common companions include [task_log](task_log.md), [tasks](tasks.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `task_log_id` | Identifier of the related task log record used by this row. | `int4` | Yes | No | [task_log](task_log.md) via (`task_log_id` -> `id`) | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `text(2147483647)` | No | No | - | - |
| `reference_center` | Center component of the composite reference to the related reference record. | `int4` | Yes | No | - | - |
| `reference_id` | Identifier component of the composite reference to the related reference record. | `int4` | Yes | No | - | - |
| `reference_sub_id` | Identifier for the related reference sub entity used by this record. | `int4` | Yes | No | - | - |
| `reference_table` | Business attribute `reference_table` used by task log details workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `VALUE` | Operational field `VALUE` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [task_log](task_log.md) (23 query files), [tasks](tasks.md) (23 query files), [persons](persons.md) (22 query files), [centers](centers.md) (16 query files), [task_actions](task_actions.md) (11 query files), [task_steps](task_steps.md) (11 query files).
- FK-linked tables: outgoing FK to [task_log](task_log.md).
- Second-level FK neighborhood includes: [persons](persons.md), [task_actions](task_actions.md), [task_steps](task_steps.md), [tasks](tasks.md).
