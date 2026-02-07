# subscription_addon_product
Stores subscription-related data, including lifecycle and financial context. It is typically used where it appears in approximately 16 query files; common companions include [masterproductregister](masterproductregister.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `subscription_product_id` | Foreign key field linking this record to `masterproductregister`. | `int4` | No | Yes | [masterproductregister](masterproductregister.md) via (`subscription_product_id` -> `id`) | - | `1001` |
| `addon_product_id` | Foreign key field linking this record to `add_on_product_definition`. | `int4` | No | Yes | [add_on_product_definition](add_on_product_definition.md) via (`addon_product_id` -> `id`) | - | `1001` |

# Relations
- Commonly used with: [masterproductregister](masterproductregister.md) (16 query files), [products](products.md) (16 query files), [centers](centers.md) (15 query files), [add_on_product_definition](add_on_product_definition.md) (12 query files), [add_on_to_product_group_link](add_on_to_product_group_link.md) (12 query files), [product_group](product_group.md) (12 query files).
- FK-linked tables: outgoing FK to [add_on_product_definition](add_on_product_definition.md), [masterproductregister](masterproductregister.md).
- Second-level FK neighborhood includes: [add_on_to_product_group_link](add_on_to_product_group_link.md), [frequent_products_item](frequent_products_item.md), [installment_plan_configs](installment_plan_configs.md), [master_prod_and_prod_grp_link](master_prod_and_prod_grp_link.md), [masterproductgroups](masterproductgroups.md), [mpr_ipc](mpr_ipc.md), [product_account_configurations](product_account_configurations.md), [product_availability](product_availability.md), [product_group](product_group.md), [subscription_addon](subscription_addon.md).
