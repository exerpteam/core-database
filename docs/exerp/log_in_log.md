# log_in_log
Stores historical/log records for log in events and changes. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `employee_center` | Center part of the reference to related employee data. | `int4` | No | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) |
| `employee_id` | Identifier of the related employee record. | `int4` | No | No | - | - |
| `log_in_time` | Epoch timestamp for log in. | `int8` | No | No | - | - |
| `log_out_time` | Epoch timestamp for log out. | `int8` | Yes | No | - | - |
| `client_instance_id` | Foreign key field linking this record to `client_instances`. | `int4` | No | No | [client_instances](client_instances.md) via (`client_instance_id` -> `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [client_instances](client_instances.md).
- Second-level FK neighborhood includes: [clients](clients.md), [error_reports](error_reports.md).
