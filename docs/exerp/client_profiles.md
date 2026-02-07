# client_profiles
Operational table for client profiles records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `profile_name` | Business attribute `profile_name` used by client profiles workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |
| `configuration` | Serialized configuration payload used by runtime processing steps. | `bytea` | Yes | No | - | - |
| `client_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |

# Relations
- FK-linked tables: incoming FK from [frequent_products_list](frequent_products_list.md), [product_group](product_group.md).
- Second-level FK neighborhood includes: [add_on_to_product_group_link](add_on_to_product_group_link.md), [colour_groups](colour_groups.md), [frequent_products_item](frequent_products_item.md), [master_prod_and_prod_grp_link](master_prod_and_prod_grp_link.md), [masterproductregister](masterproductregister.md), [product_account_configurations](product_account_configurations.md), [product_and_product_group_link](product_and_product_group_link.md), [products](products.md).
