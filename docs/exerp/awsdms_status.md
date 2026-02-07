# awsdms_status
Operational table for awsdms status records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `server_name` | Text field containing descriptive or reference information. | `VARCHAR(128)` | No | No | - | - |
| `task_name` | Text field containing descriptive or reference information. | `VARCHAR(128)` | No | No | - | - |
| `task_status` | Text field containing descriptive or reference information. | `VARCHAR(32)` | Yes | No | - | - |
| `status_time` | Epoch timestamp for status. | `TIMESTAMP` | Yes | No | - | - |
| `pending_changes` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `disk_swap_size` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `task_memory` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `source_current_position` | Text field containing descriptive or reference information. | `VARCHAR(128)` | Yes | No | - | - |
| `source_current_timestamp` | Table field used by operational and reporting workloads. | `TIMESTAMP` | Yes | No | - | - |
| `source_tail_position` | Text field containing descriptive or reference information. | `VARCHAR(128)` | Yes | No | - | - |
| `source_tail_timestamp` | Table field used by operational and reporting workloads. | `TIMESTAMP` | Yes | No | - | - |
| `source_timestamp_applied` | Table field used by operational and reporting workloads. | `TIMESTAMP` | Yes | No | - | - |

# Relations
