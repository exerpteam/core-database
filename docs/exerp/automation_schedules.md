# automation_schedules
Operational table for automation schedules records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `entry_time` | Epoch timestamp for entry. | `TIMESTAMP` | No | No | - | - | `Sample` |
| `schedule_type` | Text field containing descriptive or reference information. | `VARCHAR(30)` | No | No | - | - | `Sample value` |
| `schedule_configuration` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `status` | Lifecycle status code for the record. | `VARCHAR(25)` | No | No | - | - | `1` |
| `automation_type` | Text field containing descriptive or reference information. | `VARCHAR(30)` | No | No | - | - | `Sample value` |
| `automation_key` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `next_time_to_run` | Table field used by operational and reporting workloads. | `TIMESTAMP` | Yes | No | - | - | `N/A` |

# Relations
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
