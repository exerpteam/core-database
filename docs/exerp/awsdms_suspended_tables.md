# awsdms_suspended_tables
Operational table for awsdms suspended tables records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `server_name` | Business attribute `server_name` used by awsdms suspended tables workflows and reporting. | `VARCHAR(128)` | No | No | - | - |
| `task_name` | Business attribute `task_name` used by awsdms suspended tables workflows and reporting. | `VARCHAR(128)` | No | No | - | - |
| `table_owner` | Business attribute `table_owner` used by awsdms suspended tables workflows and reporting. | `VARCHAR(128)` | No | No | - | - |
| `table_name` | Business attribute `table_name` used by awsdms suspended tables workflows and reporting. | `VARCHAR(128)` | No | No | - | - |
| `suspend_reason` | Business attribute `suspend_reason` used by awsdms suspended tables workflows and reporting. | `VARCHAR(32)` | Yes | No | - | - |
| `suspend_timestamp` | Business attribute `suspend_timestamp` used by awsdms suspended tables workflows and reporting. | `TIMESTAMP` | Yes | No | - | - |

# Relations
