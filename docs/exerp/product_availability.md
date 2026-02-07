# product_availability
Operational table for product availability records in the Exerp schema. It is typically used where it appears in approximately 17 query files; common companions include [centers](centers.md), [masterproductregister](masterproductregister.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `product_master_key` | Identifier of the related masterproductregister record used by this row. | `int4` | No | No | [masterproductregister](masterproductregister.md) via (`product_master_key` -> `id`) | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (17 query files), [masterproductregister](masterproductregister.md) (17 query files), [products](products.md) (14 query files), [areas](areas.md) (10 query files), [area_centers](area_centers.md) (9 query files), [product_and_product_group_link](product_and_product_group_link.md) (7 query files).
- FK-linked tables: outgoing FK to [masterproductregister](masterproductregister.md).
- Second-level FK neighborhood includes: [add_on_product_definition](add_on_product_definition.md), [frequent_products_item](frequent_products_item.md), [installment_plan_configs](installment_plan_configs.md), [master_prod_and_prod_grp_link](master_prod_and_prod_grp_link.md), [masterproductgroups](masterproductgroups.md), [mpr_ipc](mpr_ipc.md), [product_account_configurations](product_account_configurations.md), [product_group](product_group.md), [subscription_addon_product](subscription_addon_product.md), [subscription_change_fees](subscription_change_fees.md).
