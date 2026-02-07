# add_on_product_definition
Operational table for add on product definition records in the Exerp schema. It is typically used where it appears in approximately 18 query files; common companions include [masterproductregister](masterproductregister.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | [masterproductregister](masterproductregister.md) via (`id` -> `id`) | - |
| `price_period_count` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `price_period_unit` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `scope_selection` | Business attribute `scope_selection` used by add on product definition workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `include_home_center` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `required` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `secondary_membership` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `secondary_membership_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `sec_mem_age_restriction_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `sec_mem_age_restriction_value` | Business attribute `sec_mem_age_restriction_value` used by add on product definition workflows and reporting. | `int4` | Yes | No | - | - |
| `sec_mem_sex_restriction_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `quantity_min` | Business attribute `quantity_min` used by add on product definition workflows and reporting. | `int4` | Yes | No | - | - |
| `quantity_max` | Business attribute `quantity_max` used by add on product definition workflows and reporting. | `int4` | Yes | No | - | - |
| `quantity_default` | Business attribute `quantity_default` used by add on product definition workflows and reporting. | `int4` | Yes | No | - | - |
| `num_secondary_members_per_unit` | Business attribute `num_secondary_members_per_unit` used by add on product definition workflows and reporting. | `int4` | Yes | No | - | - |
| `use_individual_price` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `freeze_fee_product_id` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `include_in_pro_rata_period` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `binding_period_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `binding_period_unit` | Business attribute `binding_period_unit` used by add on product definition workflows and reporting. | `int4` | Yes | No | - | - |
| `start_date_restriction` | Business attribute `start_date_restriction` used by add on product definition workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `added_by_default` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `sec_mem_age_rest_min_value` | Business attribute `sec_mem_age_rest_min_value` used by add on product definition workflows and reporting. | `int4` | Yes | No | - | - |
| `sec_mem_age_rest_max_value` | Business attribute `sec_mem_age_rest_max_value` used by add on product definition workflows and reporting. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [masterproductregister](masterproductregister.md) (18 query files), [products](products.md) (18 query files), [centers](centers.md) (17 query files), [product_group](product_group.md) (17 query files), [add_on_to_product_group_link](add_on_to_product_group_link.md) (12 query files), [subscription_addon_product](subscription_addon_product.md) (12 query files).
- FK-linked tables: outgoing FK to [masterproductregister](masterproductregister.md); incoming FK from [add_on_to_product_group_link](add_on_to_product_group_link.md), [subscription_addon](subscription_addon.md), [subscription_addon_product](subscription_addon_product.md).
- Second-level FK neighborhood includes: [frequent_products_item](frequent_products_item.md), [installment_plan_configs](installment_plan_configs.md), [master_prod_and_prod_grp_link](master_prod_and_prod_grp_link.md), [masterproductgroups](masterproductgroups.md), [mpr_ipc](mpr_ipc.md), [product_account_configurations](product_account_configurations.md), [product_availability](product_availability.md), [product_group](product_group.md), [secondary_memberships](secondary_memberships.md), [subscription_change_fees](subscription_change_fees.md).
