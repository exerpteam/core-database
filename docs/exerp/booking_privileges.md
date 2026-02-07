# booking_privileges
Operational table for booking privileges records in the Exerp schema. It is typically used where it appears in approximately 32 query files; common companions include [privilege_grants](privilege_grants.md), [privilege_sets](privilege_sets.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `privilege_set` | Identifier of the related privilege sets record used by this row. | `int4` | Yes | No | [privilege_sets](privilege_sets.md) via (`privilege_set` -> `id`) | - |
| `valid_for` | Business attribute `valid_for` used by booking privileges workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `valid_from` | Operational field `valid_from` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `valid_to` | Operational field `valid_to` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `group_id` | Identifier of the related booking privilege groups record used by this row. | `int4` | No | No | [booking_privilege_groups](booking_privilege_groups.md) via (`group_id` -> `id`) | - |
| `max_open` | Business attribute `max_open` used by booking privileges workflows and reporting. | `int4` | Yes | No | - | - |
| `time_conf` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `tentative_only` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `cutoff_time_setting_id` | Identifier for the related cutoff time setting entity used by this record. | `int4` | Yes | No | - | - |
| `in_advance_threshold` | Business attribute `in_advance_threshold` used by booking privileges workflows and reporting. | `int4` | Yes | No | - | - |
| `requires_manual_selection` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |

# Relations
- Commonly used with: [privilege_grants](privilege_grants.md) (27 query files), [privilege_sets](privilege_sets.md) (27 query files), [masterproductregister](masterproductregister.md) (25 query files), [products](products.md) (25 query files), [centers](centers.md) (24 query files), [persons](persons.md) (21 query files).
- FK-linked tables: outgoing FK to [booking_privilege_groups](booking_privilege_groups.md), [privilege_sets](privilege_sets.md).
- Second-level FK neighborhood includes: [booking_resources](booking_resources.md), [participation_configurations](participation_configurations.md), [privilege_grants](privilege_grants.md), [privilege_set_includes](privilege_set_includes.md), [product_privileges](product_privileges.md).
