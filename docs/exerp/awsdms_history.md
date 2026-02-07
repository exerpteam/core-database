# awsdms_history
Stores historical/log records for awsdms events and changes.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `server_name` | Text field containing descriptive or reference information. | `VARCHAR(128)` | No | No | - | - | `Example Name` |
| `task_name` | Text field containing descriptive or reference information. | `VARCHAR(128)` | No | No | - | - | `Example Name` |
| `timeslot_type` | Text field containing descriptive or reference information. | `VARCHAR(32)` | No | No | - | - | `Sample value` |
| `timeslot` | Table field used by operational and reporting workloads. | `TIMESTAMP` | No | No | - | - | `Sample` |
| `timeslot_duration` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `1738281600000` |
| `timeslot_latency` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `1738281600000` |
| `timeslot_records` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `1738281600000` |
| `timeslot_volume` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `1738281600000` |

# Relations
