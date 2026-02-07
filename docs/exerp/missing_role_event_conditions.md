# missing_role_event_conditions
Operational table for missing role event conditions records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `role_id` | Identifier of the related role record. | `int4` | No | No | - | [roles](roles.md) via (`role_id` -> `id`) | `1001` |

# Relations
