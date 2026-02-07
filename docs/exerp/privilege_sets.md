# privilege_sets
Operational table for privilege sets records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 252 query files; common companions include [privilege_grants](privilege_grants.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - | `1001` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `blocked_on` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `privilege_set_groups_id` | Identifier of the related privilege set groups record. | `int4` | Yes | No | - | [privilege_set_groups](privilege_set_groups.md) via (`privilege_set_groups_id` -> `id`) | `1001` |
| `time_restriction` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `booking_window_restriction` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `frequency_restriction_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `frequency_restriction_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `frequency_restriction_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `frequency_restriction_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `frequency_restr_include_noshow` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `reusable` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `availability_period_id` | Identifier of the related availability period record. | `int4` | Yes | No | - | [availability_periods](availability_periods.md) via (`availability_period_id` -> `id`) | `1001` |
| `multiaccess_window_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `multiaccess_window_time_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `multiaccess_window_time_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `multiaccess_window_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [privilege_grants](privilege_grants.md) (227 query files), [products](products.md) (180 query files), [centers](centers.md) (141 query files), [persons](persons.md) (141 query files), [masterproductregister](masterproductregister.md) (121 query files), [product_group](product_group.md) (104 query files).
- FK-linked tables: incoming FK from [booking_privileges](booking_privileges.md), [privilege_grants](privilege_grants.md), [privilege_set_includes](privilege_set_includes.md), [product_privileges](product_privileges.md).
- Second-level FK neighborhood includes: [booking_privilege_groups](booking_privilege_groups.md), [privilege_cache](privilege_cache.md), [privilege_punishments](privilege_punishments.md), [privilege_usages](privilege_usages.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
