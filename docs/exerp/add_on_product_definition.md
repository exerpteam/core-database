# add_on_product_definition
Operational table for add on product definition records in the Exerp schema. It is typically used where it appears in approximately 18 query files; common companions include [masterproductregister](masterproductregister.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [masterproductregister](masterproductregister.md) via (`id` -> `id`) | - |
| `price_period_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `price_period_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `scope_selection` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `include_home_center` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `required` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `secondary_membership` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `secondary_membership_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `sec_mem_age_restriction_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `sec_mem_age_restriction_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `sec_mem_sex_restriction_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `quantity_min` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `quantity_max` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `quantity_default` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `num_secondary_members_per_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `use_individual_price` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `freeze_fee_product_id` | Identifier of the related freeze fee product record. | `int4` | Yes | No | - | - |
| `include_in_pro_rata_period` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `binding_period_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `binding_period_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `start_date_restriction` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `added_by_default` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `sec_mem_age_rest_min_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `sec_mem_age_rest_max_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [masterproductregister](masterproductregister.md) (18 query files), [products](products.md) (18 query files), [centers](centers.md) (17 query files), [product_group](product_group.md) (17 query files), [add_on_to_product_group_link](add_on_to_product_group_link.md) (12 query files), [subscription_addon_product](subscription_addon_product.md) (12 query files).
- FK-linked tables: outgoing FK to [masterproductregister](masterproductregister.md); incoming FK from [add_on_to_product_group_link](add_on_to_product_group_link.md), [subscription_addon](subscription_addon.md), [subscription_addon_product](subscription_addon_product.md).
- Second-level FK neighborhood includes: [frequent_products_item](frequent_products_item.md), [installment_plan_configs](installment_plan_configs.md), [master_prod_and_prod_grp_link](master_prod_and_prod_grp_link.md), [masterproductgroups](masterproductgroups.md), [mpr_ipc](mpr_ipc.md), [product_account_configurations](product_account_configurations.md), [product_availability](product_availability.md), [product_group](product_group.md), [secondary_memberships](secondary_memberships.md), [subscription_change_fees](subscription_change_fees.md).
