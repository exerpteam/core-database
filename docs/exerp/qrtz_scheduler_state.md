# qrtz_scheduler_state
Operational table for qrtz scheduler state records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `instance_name` | Text field containing descriptive or reference information. | `VARCHAR(200)` | No | Yes | - | - | `Example Name` |
| `last_checkin_time` | Epoch timestamp for last checkin. | `float8(17,17)` | No | No | - | - | `Sample` |
| `checkin_interval` | Table field used by operational and reporting workloads. | `float8(17,17)` | No | No | - | - | `Sample` |

# Relations
