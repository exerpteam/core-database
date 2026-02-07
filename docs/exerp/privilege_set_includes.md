# privilege_set_includes
Operational table for privilege set includes records in the Exerp schema. It is typically used where it appears in approximately 18 query files; common companions include [privilege_grants](privilege_grants.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `parent_id` | Identifier of the related privilege sets record used by this row. | `int4` | Yes | No | [privilege_sets](privilege_sets.md) via (`parent_id` -> `id`) | - |
| `child_id` | Identifier of the related privilege sets record used by this row. | `int4` | Yes | No | [privilege_sets](privilege_sets.md) via (`child_id` -> `id`) | - |
| `valid_from` | Operational field `valid_from` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `valid_to` | Operational field `valid_to` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [privilege_grants](privilege_grants.md) (14 query files), [centers](centers.md) (10 query files), [product_group](product_group.md) (9 query files), [area_centers](area_centers.md) (8 query files), [areas](areas.md) (8 query files), [privilege_receiver_groups](privilege_receiver_groups.md) (8 query files).
- FK-linked tables: outgoing FK to [privilege_sets](privilege_sets.md).
- Second-level FK neighborhood includes: [booking_privileges](booking_privileges.md), [privilege_grants](privilege_grants.md), [product_privileges](product_privileges.md).
