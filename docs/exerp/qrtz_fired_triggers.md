# qrtz_fired_triggers
Operational table for qrtz fired triggers records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `entry_id` | Identifier of the related entry record. | `VARCHAR(95)` | No | Yes | - | - | `1001` |
| `trigger_name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `trigger_group` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `is_volatile` | Boolean flag indicating whether volatile applies. | `bool` | No | No | - | - | `true` |
| `instance_name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `fired_time` | Epoch timestamp for fired. | `float8(17,17)` | No | No | - | - | `Sample` |
| `priority` | Table field used by operational and reporting workloads. | `float8(17,17)` | No | No | - | - | `Sample` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `job_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `job_group` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `is_stateful` | Boolean flag indicating whether stateful applies. | `bool` | Yes | No | - | - | `true` |
| `requests_recovery` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |

# Relations
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
