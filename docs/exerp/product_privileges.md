# product_privileges
Operational table for product privileges records in the Exerp schema. It is typically used where it appears in approximately 163 query files; common companions include [products](products.md), [privilege_grants](privilege_grants.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `privilege_set` | Foreign key field linking this record to `privilege_sets`. | `int4` | Yes | No | [privilege_sets](privilege_sets.md) via (`privilege_set` -> `id`) | - |
| `valid_for` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `valid_from` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `valid_to` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `price_modification_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `price_modification_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `price_modification_rounding` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `ref_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `ref_globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `ref_center` | Center part of the reference to related ref data. | `int4` | Yes | No | - | - |
| `ref_id` | Identifier of the related ref record. | `int4` | Yes | No | - | - |
| `disable_min_price` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `purchase_right` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [products](products.md) (157 query files), [privilege_grants](privilege_grants.md) (143 query files), [persons](persons.md) (135 query files), [subscriptions](subscriptions.md) (115 query files), [companyagreements](companyagreements.md) (109 query files), [centers](centers.md) (107 query files).
- FK-linked tables: outgoing FK to [privilege_sets](privilege_sets.md).
- Second-level FK neighborhood includes: [booking_privileges](booking_privileges.md), [privilege_grants](privilege_grants.md), [privilege_set_includes](privilege_set_includes.md).
