# privilege_sets
Operational table for privilege sets records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 252 query files; common companions include [privilege_grants](privilege_grants.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | [privilege_sets_scope_type](../master%20tables/privilege_sets_scope_type.md) |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `blocked_on` | Business attribute `blocked_on` used by privilege sets workflows and reporting. | `int8` | Yes | No | - | - |
| `privilege_set_groups_id` | Identifier for the related privilege set groups entity used by this record. | `int4` | Yes | No | - | [privilege_set_groups](privilege_set_groups.md) via (`privilege_set_groups_id` -> `id`) |
| `time_restriction` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `booking_window_restriction` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `frequency_restriction_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `frequency_restriction_value` | Business attribute `frequency_restriction_value` used by privilege sets workflows and reporting. | `int4` | Yes | No | - | - |
| `frequency_restriction_unit` | Business attribute `frequency_restriction_unit` used by privilege sets workflows and reporting. | `int4` | Yes | No | - | - |
| `frequency_restriction_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `frequency_restr_include_noshow` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `reusable` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `availability_period_id` | Identifier for the related availability period entity used by this record. | `int4` | Yes | No | - | [availability_periods](availability_periods.md) via (`availability_period_id` -> `id`) |
| `multiaccess_window_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `multiaccess_window_time_value` | Business attribute `multiaccess_window_time_value` used by privilege sets workflows and reporting. | `int4` | Yes | No | - | - |
| `multiaccess_window_time_unit` | Business attribute `multiaccess_window_time_unit` used by privilege sets workflows and reporting. | `int4` | Yes | No | - | - |
| `multiaccess_window_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [privilege_grants](privilege_grants.md) (227 query files), [products](products.md) (180 query files), [centers](centers.md) (141 query files), [persons](persons.md) (141 query files), [masterproductregister](masterproductregister.md) (121 query files), [product_group](product_group.md) (104 query files).
- FK-linked tables: incoming FK from [booking_privileges](booking_privileges.md), [privilege_grants](privilege_grants.md), [privilege_set_includes](privilege_set_includes.md), [product_privileges](product_privileges.md).
- Second-level FK neighborhood includes: [booking_privilege_groups](booking_privilege_groups.md), [privilege_cache](privilege_cache.md), [privilege_punishments](privilege_punishments.md), [privilege_usages](privilege_usages.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
