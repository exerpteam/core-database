# jbm_user
Operational table for jbm user records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `user_id` | Identifier of the related user record. | `VARCHAR(32)` | No | Yes | - | - |
| `passwd` | Text field containing descriptive or reference information. | `VARCHAR(32)` | No | No | - | - |
| `clientid` | Text field containing descriptive or reference information. | `VARCHAR(128)` | Yes | No | - | - |

# Relations
