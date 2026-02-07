# awsdms_apply_exceptions
Operational table for awsdms apply exceptions records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `TASK_NAME` | Text field containing descriptive or reference information. | `VARCHAR(128)` | No | No | - | - | `Example Name` |
| `TABLE_OWNER` | Text field containing descriptive or reference information. | `VARCHAR(128)` | No | No | - | - | `Sample value` |
| `TABLE_NAME` | Text field containing descriptive or reference information. | `VARCHAR(128)` | No | No | - | - | `Example Name` |
| `ERROR_TIME` | Epoch timestamp for error. | `TIMESTAMP` | No | No | - | - | `Sample` |
| `STATEMENT` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `ERROR` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |

# Relations
