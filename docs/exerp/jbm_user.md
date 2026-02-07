# jbm_user
Operational table for jbm user records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `user_id` | Identifier of the related user record. | `VARCHAR(32)` | No | Yes | - | - | `1001` |
| `passwd` | Text field containing descriptive or reference information. | `VARCHAR(32)` | No | No | - | - | `Sample value` |
| `clientid` | Text field containing descriptive or reference information. | `VARCHAR(128)` | Yes | No | - | - | `Sample value` |

# Relations
