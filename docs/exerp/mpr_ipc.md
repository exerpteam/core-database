# mpr_ipc
Operational table for mpr ipc records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `selecting_product_id` | Foreign key field linking this record to `masterproductregister`. | `int4` | No | No | [masterproductregister](masterproductregister.md) via (`selecting_product_id` -> `id`) | - | `1001` |
| `selected_ipc_id` | Foreign key field linking this record to `installment_plan_configs`. | `int4` | No | No | [installment_plan_configs](installment_plan_configs.md) via (`selected_ipc_id` -> `id`) | - | `1001` |
| `created` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `42` |

# Relations
- FK-linked tables: outgoing FK to [installment_plan_configs](installment_plan_configs.md), [masterproductregister](masterproductregister.md).
- Second-level FK neighborhood includes: [add_on_product_definition](add_on_product_definition.md), [frequent_products_item](frequent_products_item.md), [installment_plans](installment_plans.md), [master_prod_and_prod_grp_link](master_prod_and_prod_grp_link.md), [masterproductgroups](masterproductgroups.md), [product_account_configurations](product_account_configurations.md), [product_availability](product_availability.md), [product_group](product_group.md), [subscription_addon_product](subscription_addon_product.md), [subscription_change_fees](subscription_change_fees.md).
