# jbm_role
Operational table for jbm role records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `role_id` | Identifier of the related role record. | `VARCHAR(32)` | No | Yes | - | [roles](roles.md) via (`role_id` -> `id`) |
| `user_id` | Identifier of the related user record. | `VARCHAR(32)` | No | Yes | - | - |

# Relations
