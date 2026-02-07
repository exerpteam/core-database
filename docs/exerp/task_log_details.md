# task_log_details
Stores historical/log records for task details events and changes. It is typically used where it appears in approximately 23 query files; common companions include [task_log](task_log.md), [tasks](tasks.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `task_log_id` | Foreign key field linking this record to `task_log`. | `int4` | Yes | No | [task_log](task_log.md) via (`task_log_id` -> `id`) | - |
| `type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `reference_center` | Center part of the reference to related reference data. | `int4` | Yes | No | - | - |
| `reference_id` | Identifier of the related reference record. | `int4` | Yes | No | - | - |
| `reference_sub_id` | Identifier of the related reference sub record. | `int4` | Yes | No | - | - |
| `reference_table` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `VALUE` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [task_log](task_log.md) (23 query files), [tasks](tasks.md) (23 query files), [persons](persons.md) (22 query files), [centers](centers.md) (16 query files), [task_actions](task_actions.md) (11 query files), [task_steps](task_steps.md) (11 query files).
- FK-linked tables: outgoing FK to [task_log](task_log.md).
- Second-level FK neighborhood includes: [persons](persons.md), [task_actions](task_actions.md), [task_steps](task_steps.md), [tasks](tasks.md).
