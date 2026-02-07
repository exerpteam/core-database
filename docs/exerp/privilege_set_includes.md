# privilege_set_includes
Operational table for privilege set includes records in the Exerp schema. It is typically used where it appears in approximately 18 query files; common companions include [privilege_grants](privilege_grants.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `parent_id` | Foreign key field linking this record to `privilege_sets`. | `int4` | Yes | No | [privilege_sets](privilege_sets.md) via (`parent_id` -> `id`) | - | `1001` |
| `child_id` | Foreign key field linking this record to `privilege_sets`. | `int4` | Yes | No | [privilege_sets](privilege_sets.md) via (`child_id` -> `id`) | - | `1001` |
| `valid_from` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `42` |
| `valid_to` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [privilege_grants](privilege_grants.md) (14 query files), [centers](centers.md) (10 query files), [product_group](product_group.md) (9 query files), [area_centers](area_centers.md) (8 query files), [areas](areas.md) (8 query files), [privilege_receiver_groups](privilege_receiver_groups.md) (8 query files).
- FK-linked tables: outgoing FK to [privilege_sets](privilege_sets.md).
- Second-level FK neighborhood includes: [booking_privileges](booking_privileges.md), [privilege_grants](privilege_grants.md), [product_privileges](product_privileges.md).
