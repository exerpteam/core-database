# jbm_user
Operational table for jbm user records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `user_id` | Primary key identifier for this record. | `VARCHAR(32)` | No | Yes | - | - |
| `passwd` | Business attribute `passwd` used by jbm user workflows and reporting. | `VARCHAR(32)` | No | No | - | - |
| `clientid` | Business attribute `clientid` used by jbm user workflows and reporting. | `VARCHAR(128)` | Yes | No | - | - |

# Relations
