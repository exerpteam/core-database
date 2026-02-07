# mpr_ipc
Operational table for mpr ipc records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `selecting_product_id` | Identifier of the related masterproductregister record used by this row. | `int4` | No | No | [masterproductregister](masterproductregister.md) via (`selecting_product_id` -> `id`) | - |
| `selected_ipc_id` | Identifier of the related installment plan configs record used by this row. | `int4` | No | No | [installment_plan_configs](installment_plan_configs.md) via (`selected_ipc_id` -> `id`) | - |
| `created` | Operational field `created` used in query filtering and reporting transformations. | `int8` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [installment_plan_configs](installment_plan_configs.md), [masterproductregister](masterproductregister.md).
- Second-level FK neighborhood includes: [add_on_product_definition](add_on_product_definition.md), [frequent_products_item](frequent_products_item.md), [installment_plans](installment_plans.md), [master_prod_and_prod_grp_link](master_prod_and_prod_grp_link.md), [masterproductgroups](masterproductgroups.md), [product_account_configurations](product_account_configurations.md), [product_availability](product_availability.md), [product_group](product_group.md), [subscription_addon_product](subscription_addon_product.md), [subscription_change_fees](subscription_change_fees.md).
