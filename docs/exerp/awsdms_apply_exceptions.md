# awsdms_apply_exceptions
Operational table for awsdms apply exceptions records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `TASK_NAME` | Business attribute `TASK_NAME` used by awsdms apply exceptions workflows and reporting. | `VARCHAR(128)` | No | No | - | - |
| `TABLE_OWNER` | Business attribute `TABLE_OWNER` used by awsdms apply exceptions workflows and reporting. | `VARCHAR(128)` | No | No | - | - |
| `TABLE_NAME` | Business attribute `TABLE_NAME` used by awsdms apply exceptions workflows and reporting. | `VARCHAR(128)` | No | No | - | - |
| `ERROR_TIME` | Timestamp used for event ordering and operational tracking. | `TIMESTAMP` | No | No | - | - |
| `STATEMENT` | State indicator used to control lifecycle transitions and filtering. | `text(2147483647)` | No | No | - | - |
| `ERROR` | Operational field `ERROR` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |

# Relations
