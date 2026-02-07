# awsdms_suspended_tables
Operational table for awsdms suspended tables records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `server_name` | Text field containing descriptive or reference information. | `VARCHAR(128)` | No | No | - | - | `Example Name` |
| `task_name` | Text field containing descriptive or reference information. | `VARCHAR(128)` | No | No | - | - | `Example Name` |
| `table_owner` | Text field containing descriptive or reference information. | `VARCHAR(128)` | No | No | - | - | `Sample value` |
| `table_name` | Text field containing descriptive or reference information. | `VARCHAR(128)` | No | No | - | - | `Example Name` |
| `suspend_reason` | Text field containing descriptive or reference information. | `VARCHAR(32)` | Yes | No | - | - | `Sample value` |
| `suspend_timestamp` | Table field used by operational and reporting workloads. | `TIMESTAMP` | Yes | No | - | - | `N/A` |

# Relations
