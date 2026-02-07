# log_in_log
Stores historical/log records for log in events and changes. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | No | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | No | No | - | - |
| `log_in_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `log_out_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `client_instance_id` | Identifier of the related client instances record used by this row. | `int4` | No | No | [client_instances](client_instances.md) via (`client_instance_id` -> `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [client_instances](client_instances.md).
- Second-level FK neighborhood includes: [clients](clients.md), [error_reports](error_reports.md).
