# jbm_role
Operational table for jbm role records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `role_id` | Identifier of the related role record. | `VARCHAR(32)` | No | Yes | - | [roles](roles.md) via (`role_id` -> `id`) | `1001` |
| `user_id` | Identifier of the related user record. | `VARCHAR(32)` | No | Yes | - | - | `1001` |

# Relations
