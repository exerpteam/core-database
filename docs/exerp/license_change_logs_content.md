# license_change_logs_content
Stores historical/log records for license changes content events and changes.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `license_change_log_id` | Identifier of the related license change logs record used by this row. | `int4` | No | No | [license_change_logs](license_change_logs.md) via (`license_change_log_id` -> `id`) | - |
| `license_id` | Identifier of the related licenses record used by this row. | `int4` | No | No | [licenses](licenses.md) via (`license_id` -> `id`) | - |
| `change_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `value_before` | Business attribute `value_before` used by license change logs content workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `value_after` | Business attribute `value_after` used by license change logs content workflows and reporting. | `text(2147483647)` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [license_change_logs](license_change_logs.md), [licenses](licenses.md).
- Second-level FK neighborhood includes: [centers](centers.md), [contracts](contracts.md), [employees](employees.md).
