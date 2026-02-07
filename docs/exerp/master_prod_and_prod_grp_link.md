# master_prod_and_prod_grp_link
Bridge table that links related entities for master prod and prod grp link relationships. It is typically used where it appears in approximately 16 query files; common companions include [masterproductregister](masterproductregister.md), [privilege_grants](privilege_grants.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `master_product_id` | Foreign key field linking this record to `masterproductregister`. | `int4` | No | Yes | [masterproductregister](masterproductregister.md) via (`master_product_id` -> `id`) | - |
| `product_group_id` | Foreign key field linking this record to `product_group`. | `int4` | No | Yes | [product_group](product_group.md) via (`product_group_id` -> `id`) | - |

# Relations
- Commonly used with: [masterproductregister](masterproductregister.md) (16 query files), [privilege_grants](privilege_grants.md) (14 query files), [product_group](product_group.md) (14 query files), [privilege_sets](privilege_sets.md) (13 query files), [areas](areas.md) (12 query files), [centers](centers.md) (12 query files).
- FK-linked tables: outgoing FK to [masterproductregister](masterproductregister.md), [product_group](product_group.md).
- Second-level FK neighborhood includes: [add_on_product_definition](add_on_product_definition.md), [add_on_to_product_group_link](add_on_to_product_group_link.md), [client_profiles](client_profiles.md), [colour_groups](colour_groups.md), [frequent_products_item](frequent_products_item.md), [installment_plan_configs](installment_plan_configs.md), [masterproductgroups](masterproductgroups.md), [mpr_ipc](mpr_ipc.md), [product_account_configurations](product_account_configurations.md), [product_and_product_group_link](product_and_product_group_link.md).
