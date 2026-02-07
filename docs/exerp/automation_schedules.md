# automation_schedules
Operational table for automation schedules records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `entry_time` | Epoch timestamp for entry. | `TIMESTAMP` | No | No | - | - |
| `schedule_type` | Text field containing descriptive or reference information. | `VARCHAR(30)` | No | No | - | - |
| `schedule_configuration` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `status` | Lifecycle status code for the record. | `VARCHAR(25)` | No | No | - | - |
| `automation_type` | Text field containing descriptive or reference information. | `VARCHAR(30)` | No | No | - | - |
| `automation_key` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `next_time_to_run` | Table field used by operational and reporting workloads. | `TIMESTAMP` | Yes | No | - | - |

# Relations
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
