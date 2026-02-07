# privilege_grants
Operational table for privilege grants records in the Exerp schema. It is typically used where it appears in approximately 504 query files; common companions include [products](products.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `privilege_set` | Identifier of the related privilege sets record used by this row. | `int4` | Yes | No | [privilege_sets](privilege_sets.md) via (`privilege_set` -> `id`) | - |
| `punishment` | Identifier of the related privilege punishments record used by this row. | `int4` | Yes | No | [privilege_punishments](privilege_punishments.md) via (`punishment` -> `id`) | - |
| `granter_service` | Operational field `granter_service` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `granter_globalid` | Business attribute `granter_globalid` used by privilege grants workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `granter_center` | Center component of the composite reference to the related granter record. | `int4` | Yes | No | - | - |
| `granter_id` | Identifier component of the composite reference to the related granter record. | `int4` | Yes | No | - | - |
| `granter_subid` | Operational field `granter_subid` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `valid_from` | Operational field `valid_from` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `valid_to` | Operational field `valid_to` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `sponsorship_name` | Operational field `sponsorship_name` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `sponsorship_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `sponsorship_rounding` | Business attribute `sponsorship_rounding` used by privilege grants workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `usage_product` | Business attribute `usage_product` used by privilege grants workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `usage_quantity` | Business attribute `usage_quantity` used by privilege grants workflows and reporting. | `int4` | Yes | No | - | - |
| `usage_duration_value` | Business attribute `usage_duration_value` used by privilege grants workflows and reporting. | `int4` | Yes | No | - | - |
| `usage_duration_unit` | Business attribute `usage_duration_unit` used by privilege grants workflows and reporting. | `int4` | Yes | No | - | - |
| `usage_duration_round` | Business attribute `usage_duration_round` used by privilege grants workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `usage_use_at_planning` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `extension` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `frequency_restriction_target` | Business attribute `frequency_restriction_target` used by privilege grants workflows and reporting. | `VARCHAR(10)` | No | No | - | - |

# Relations
- Commonly used with: [products](products.md) (377 query files), [persons](persons.md) (351 query files), [centers](centers.md) (299 query files), [subscriptions](subscriptions.md) (278 query files), [privilege_sets](privilege_sets.md) (227 query files), [subscriptiontypes](subscriptiontypes.md) (213 query files).
- FK-linked tables: outgoing FK to [privilege_punishments](privilege_punishments.md), [privilege_sets](privilege_sets.md); incoming FK from [privilege_cache](privilege_cache.md), [privilege_usages](privilege_usages.md).
- Second-level FK neighborhood includes: [booking_privileges](booking_privileges.md), [campaign_codes](campaign_codes.md), [persons](persons.md), [privilege_cache_validity](privilege_cache_validity.md), [privilege_set_includes](privilege_set_includes.md), [product_privileges](product_privileges.md).
