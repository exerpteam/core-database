# missing_role_event_conditions
Operational table for missing role event conditions records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `role_id` | Identifier for the related role entity used by this record. | `int4` | No | No | - | [roles](roles.md) via (`role_id` -> `id`) |

# Relations
