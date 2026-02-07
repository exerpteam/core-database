# qrtz_scheduler_state
Operational table for qrtz scheduler state records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `instance_name` | Primary key identifier for this record. | `VARCHAR(200)` | No | Yes | - | - |
| `last_checkin_time` | Timestamp used for event ordering and operational tracking. | `float8(17,17)` | No | No | - | - |
| `checkin_interval` | Business attribute `checkin_interval` used by qrtz scheduler state workflows and reporting. | `float8(17,17)` | No | No | - | - |

# Relations
