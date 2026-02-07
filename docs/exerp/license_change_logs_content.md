# license_change_logs_content
Stores historical/log records for license changes content events and changes.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `license_change_log_id` | Foreign key field linking this record to `license_change_logs`. | `int4` | No | No | [license_change_logs](license_change_logs.md) via (`license_change_log_id` -> `id`) | - | `1001` |
| `license_id` | Foreign key field linking this record to `licenses`. | `int4` | No | No | [licenses](licenses.md) via (`license_id` -> `id`) | - | `1001` |
| `change_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `value_before` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `value_after` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |

# Relations
- FK-linked tables: outgoing FK to [license_change_logs](license_change_logs.md), [licenses](licenses.md).
- Second-level FK neighborhood includes: [centers](centers.md), [contracts](contracts.md), [employees](employees.md).
