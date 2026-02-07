# add_on_to_product_group_link
Bridge table that links related entities for add on to product group link relationships. It is typically used where it appears in approximately 12 query files; common companions include [add_on_product_definition](add_on_product_definition.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `add_on_product_definition_id` | Foreign key field linking this record to `add_on_product_definition`. | `int4` | No | Yes | [add_on_product_definition](add_on_product_definition.md) via (`add_on_product_definition_id` -> `id`) | - |
| `product_group_id` | Foreign key field linking this record to `product_group`. | `int4` | No | Yes | [product_group](product_group.md) via (`product_group_id` -> `id`) | - |

# Relations
- Commonly used with: [add_on_product_definition](add_on_product_definition.md) (12 query files), [centers](centers.md) (12 query files), [masterproductregister](masterproductregister.md) (12 query files), [product_group](product_group.md) (12 query files), [products](products.md) (12 query files), [subscription_addon_product](subscription_addon_product.md) (12 query files).
- FK-linked tables: outgoing FK to [add_on_product_definition](add_on_product_definition.md), [product_group](product_group.md).
- Second-level FK neighborhood includes: [client_profiles](client_profiles.md), [colour_groups](colour_groups.md), [master_prod_and_prod_grp_link](master_prod_and_prod_grp_link.md), [masterproductregister](masterproductregister.md), [product_account_configurations](product_account_configurations.md), [product_and_product_group_link](product_and_product_group_link.md), [products](products.md), [subscription_addon](subscription_addon.md), [subscription_addon_product](subscription_addon_product.md).
