# product_privileges
Operational table for product privileges records in the Exerp schema. It is typically used where it appears in approximately 163 query files; common companions include [products](products.md), [privilege_grants](privilege_grants.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `privilege_set` | Identifier of the related privilege sets record used by this row. | `int4` | Yes | No | [privilege_sets](privilege_sets.md) via (`privilege_set` -> `id`) | - |
| `valid_for` | Business attribute `valid_for` used by product privileges workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `valid_from` | Operational field `valid_from` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `valid_to` | Operational field `valid_to` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `price_modification_name` | Monetary value used in financial calculation, settlement, or reporting. | `text(2147483647)` | Yes | No | - | - |
| `price_modification_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `price_modification_rounding` | Monetary value used in financial calculation, settlement, or reporting. | `text(2147483647)` | Yes | No | - | - |
| `ref_type` | Classification code describing the ref type category (for example: PERSON). | `text(2147483647)` | No | No | - | - |
| `ref_globalid` | Operational field `ref_globalid` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `ref_center` | Center component of the composite reference to the related ref record. | `int4` | Yes | No | - | - |
| `ref_id` | Identifier component of the composite reference to the related ref record. | `int4` | Yes | No | - | - |
| `disable_min_price` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `purchase_right` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [products](products.md) (157 query files), [privilege_grants](privilege_grants.md) (143 query files), [persons](persons.md) (135 query files), [subscriptions](subscriptions.md) (115 query files), [companyagreements](companyagreements.md) (109 query files), [centers](centers.md) (107 query files).
- FK-linked tables: outgoing FK to [privilege_sets](privilege_sets.md).
- Second-level FK neighborhood includes: [booking_privileges](booking_privileges.md), [privilege_grants](privilege_grants.md), [privilege_set_includes](privilege_set_includes.md).
