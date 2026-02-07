# frequent_products_item
Operational table for frequent products item records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `rank` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `frequent_products_list_id` | Foreign key field linking this record to `frequent_products_list`. | `int4` | No | Yes | [frequent_products_list](frequent_products_list.md) via (`frequent_products_list_id` -> `id`) | - |
| `product_id` | Foreign key field linking this record to `masterproductregister`. | `int4` | No | Yes | [masterproductregister](masterproductregister.md) via (`product_id` -> `id`) | - |
| `version` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [frequent_products_list](frequent_products_list.md), [masterproductregister](masterproductregister.md).
- Second-level FK neighborhood includes: [add_on_product_definition](add_on_product_definition.md), [client_profiles](client_profiles.md), [installment_plan_configs](installment_plan_configs.md), [master_prod_and_prod_grp_link](master_prod_and_prod_grp_link.md), [masterproductgroups](masterproductgroups.md), [mpr_ipc](mpr_ipc.md), [product_account_configurations](product_account_configurations.md), [product_availability](product_availability.md), [product_group](product_group.md), [subscription_addon_product](subscription_addon_product.md).
