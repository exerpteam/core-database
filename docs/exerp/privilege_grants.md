# privilege_grants
Operational table for privilege grants records in the Exerp schema. It is typically used where it appears in approximately 504 query files; common companions include [products](products.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `privilege_set` | Foreign key field linking this record to `privilege_sets`. | `int4` | Yes | No | [privilege_sets](privilege_sets.md) via (`privilege_set` -> `id`) | - |
| `punishment` | Foreign key field linking this record to `privilege_punishments`. | `int4` | Yes | No | [privilege_punishments](privilege_punishments.md) via (`punishment` -> `id`) | - |
| `granter_service` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `granter_globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `granter_center` | Center part of the reference to related granter data. | `int4` | Yes | No | - | - |
| `granter_id` | Identifier of the related granter record. | `int4` | Yes | No | - | - |
| `granter_subid` | Sub-identifier for related granter detail rows. | `int4` | Yes | No | - | - |
| `valid_from` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `valid_to` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `sponsorship_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `sponsorship_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `sponsorship_rounding` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `usage_product` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `usage_quantity` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `usage_duration_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `usage_duration_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `usage_duration_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `usage_use_at_planning` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `extension` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `frequency_restriction_target` | Text field containing descriptive or reference information. | `VARCHAR(10)` | No | No | - | - |

# Relations
- Commonly used with: [products](products.md) (377 query files), [persons](persons.md) (351 query files), [centers](centers.md) (299 query files), [subscriptions](subscriptions.md) (278 query files), [privilege_sets](privilege_sets.md) (227 query files), [subscriptiontypes](subscriptiontypes.md) (213 query files).
- FK-linked tables: outgoing FK to [privilege_punishments](privilege_punishments.md), [privilege_sets](privilege_sets.md); incoming FK from [privilege_cache](privilege_cache.md), [privilege_usages](privilege_usages.md).
- Second-level FK neighborhood includes: [booking_privileges](booking_privileges.md), [campaign_codes](campaign_codes.md), [persons](persons.md), [privilege_cache_validity](privilege_cache_validity.md), [privilege_set_includes](privilege_set_includes.md), [product_privileges](product_privileges.md).
