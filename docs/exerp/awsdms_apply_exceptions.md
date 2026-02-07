# awsdms_apply_exceptions
Operational table for awsdms apply exceptions records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `TASK_NAME` | Text field containing descriptive or reference information. | `VARCHAR(128)` | No | No | - | - |
| `TABLE_OWNER` | Text field containing descriptive or reference information. | `VARCHAR(128)` | No | No | - | - |
| `TABLE_NAME` | Text field containing descriptive or reference information. | `VARCHAR(128)` | No | No | - | - |
| `ERROR_TIME` | Epoch timestamp for error. | `TIMESTAMP` | No | No | - | - |
| `STATEMENT` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `ERROR` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |

# Relations
