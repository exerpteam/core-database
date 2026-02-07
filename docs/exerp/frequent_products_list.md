# frequent_products_list
Operational table for frequent products list records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `last_refresh` | Business attribute `last_refresh` used by frequent products list workflows and reporting. | `int8` | Yes | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `text(2147483647)` | No | No | - | - |
| `version` | Operational field `version` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `client_profile_id` | Identifier of the related client profiles record used by this row. | `int4` | Yes | No | [client_profiles](client_profiles.md) via (`client_profile_id` -> `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [client_profiles](client_profiles.md); incoming FK from [frequent_products_item](frequent_products_item.md).
- Second-level FK neighborhood includes: [masterproductregister](masterproductregister.md), [product_group](product_group.md).
