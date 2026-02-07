# frequent_products_list
Operational table for frequent products list records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `last_refresh` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `version` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `client_profile_id` | Foreign key field linking this record to `client_profiles`. | `int4` | Yes | No | [client_profiles](client_profiles.md) via (`client_profile_id` -> `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [client_profiles](client_profiles.md); incoming FK from [frequent_products_item](frequent_products_item.md).
- Second-level FK neighborhood includes: [masterproductregister](masterproductregister.md), [product_group](product_group.md).
