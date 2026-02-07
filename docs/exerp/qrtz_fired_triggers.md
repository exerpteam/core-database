# qrtz_fired_triggers
Operational table for qrtz fired triggers records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `entry_id` | Identifier of the related entry record. | `VARCHAR(95)` | No | Yes | - | - |
| `trigger_name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `trigger_group` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `is_volatile` | Boolean flag indicating whether volatile applies. | `bool` | No | No | - | - |
| `instance_name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `fired_time` | Epoch timestamp for fired. | `float8(17,17)` | No | No | - | - |
| `priority` | Table field used by operational and reporting workloads. | `float8(17,17)` | No | No | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `job_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `job_group` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `is_stateful` | Boolean flag indicating whether stateful applies. | `bool` | Yes | No | - | - |
| `requests_recovery` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |

# Relations
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
