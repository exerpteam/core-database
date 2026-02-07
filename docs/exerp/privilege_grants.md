# privilege_grants
Operational table for privilege grants records in the Exerp schema. It is typically used where it appears in approximately 504 query files; common companions include [products](products.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `privilege_set` | Foreign key field linking this record to `privilege_sets`. | `int4` | Yes | No | [privilege_sets](privilege_sets.md) via (`privilege_set` -> `id`) | - | `42` |
| `punishment` | Foreign key field linking this record to `privilege_punishments`. | `int4` | Yes | No | [privilege_punishments](privilege_punishments.md) via (`punishment` -> `id`) | - | `42` |
| `granter_service` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `granter_globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `granter_center` | Center part of the reference to related granter data. | `int4` | Yes | No | - | - | `101` |
| `granter_id` | Identifier of the related granter record. | `int4` | Yes | No | - | - | `1001` |
| `granter_subid` | Sub-identifier for related granter detail rows. | `int4` | Yes | No | - | - | `1` |
| `valid_from` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `valid_to` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `sponsorship_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `sponsorship_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `sponsorship_rounding` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `usage_product` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `usage_quantity` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `usage_duration_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `usage_duration_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `usage_duration_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `usage_use_at_planning` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `extension` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `frequency_restriction_target` | Text field containing descriptive or reference information. | `VARCHAR(10)` | No | No | - | - | `Sample value` |

# Relations
- Commonly used with: [products](products.md) (377 query files), [persons](persons.md) (351 query files), [centers](centers.md) (299 query files), [subscriptions](subscriptions.md) (278 query files), [privilege_sets](privilege_sets.md) (227 query files), [subscriptiontypes](subscriptiontypes.md) (213 query files).
- FK-linked tables: outgoing FK to [privilege_punishments](privilege_punishments.md), [privilege_sets](privilege_sets.md); incoming FK from [privilege_cache](privilege_cache.md), [privilege_usages](privilege_usages.md).
- Second-level FK neighborhood includes: [booking_privileges](booking_privileges.md), [campaign_codes](campaign_codes.md), [persons](persons.md), [privilege_cache_validity](privilege_cache_validity.md), [privilege_set_includes](privilege_set_includes.md), [product_privileges](product_privileges.md).
