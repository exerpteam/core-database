# awsdms_history
Stores historical/log records for awsdms events and changes.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `server_name` | Text field containing descriptive or reference information. | `VARCHAR(128)` | No | No | - | - |
| `task_name` | Text field containing descriptive or reference information. | `VARCHAR(128)` | No | No | - | - |
| `timeslot_type` | Text field containing descriptive or reference information. | `VARCHAR(32)` | No | No | - | - |
| `timeslot` | Table field used by operational and reporting workloads. | `TIMESTAMP` | No | No | - | - |
| `timeslot_duration` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `timeslot_latency` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `timeslot_records` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `timeslot_volume` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |

# Relations
