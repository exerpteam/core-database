# booking_privileges
Operational table for booking privileges records in the Exerp schema. It is typically used where it appears in approximately 32 query files; common companions include [privilege_grants](privilege_grants.md), [privilege_sets](privilege_sets.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `privilege_set` | Foreign key field linking this record to `privilege_sets`. | `int4` | Yes | No | [privilege_sets](privilege_sets.md) via (`privilege_set` -> `id`) | - | `42` |
| `valid_for` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `valid_from` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `valid_to` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `group_id` | Foreign key field linking this record to `booking_privilege_groups`. | `int4` | No | No | [booking_privilege_groups](booking_privilege_groups.md) via (`group_id` -> `id`) | - | `1001` |
| `max_open` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `time_conf` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `tentative_only` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `cutoff_time_setting_id` | Identifier of the related cutoff time setting record. | `int4` | Yes | No | - | - | `1001` |
| `in_advance_threshold` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `requires_manual_selection` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |

# Relations
- Commonly used with: [privilege_grants](privilege_grants.md) (27 query files), [privilege_sets](privilege_sets.md) (27 query files), [masterproductregister](masterproductregister.md) (25 query files), [products](products.md) (25 query files), [centers](centers.md) (24 query files), [persons](persons.md) (21 query files).
- FK-linked tables: outgoing FK to [booking_privilege_groups](booking_privilege_groups.md), [privilege_sets](privilege_sets.md).
- Second-level FK neighborhood includes: [booking_resources](booking_resources.md), [participation_configurations](participation_configurations.md), [privilege_grants](privilege_grants.md), [privilege_set_includes](privilege_set_includes.md), [product_privileges](product_privileges.md).
