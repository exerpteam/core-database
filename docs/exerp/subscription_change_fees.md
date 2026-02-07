# subscription_change_fees
Stores subscription-related data, including lifecycle and financial context. It is typically used where lifecycle state codes are present; it appears in approximately 3 query files; common companions include [masterproductregister](masterproductregister.md), [product_group](product_group.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `subscr_type_from` | Foreign key field linking this record to `masterproductregister`. | `int4` | Yes | No | [masterproductregister](masterproductregister.md) via (`subscr_type_from` -> `id`) | - |
| `subscr_type_to` | Foreign key field linking this record to `masterproductregister`. | `int4` | Yes | No | [masterproductregister](masterproductregister.md) via (`subscr_type_to` -> `id`) | - |
| `change_fee_product` | Foreign key field linking this record to `masterproductregister`. | `int4` | No | No | [masterproductregister](masterproductregister.md) via (`change_fee_product` -> `id`) | - |
| `type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `created` | Table field used by operational and reporting workloads. | `TIMESTAMP` | No | No | - | - |
| `modified` | Table field used by operational and reporting workloads. | `TIMESTAMP` | No | No | - | - |
| `deleted` | Table field used by operational and reporting workloads. | `TIMESTAMP` | Yes | No | - | - |
| `version` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `change_fee_percentage` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `use_remaining_contract_value` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |

# Relations
- Commonly used with: [masterproductregister](masterproductregister.md) (3 query files), [product_group](product_group.md) (2 query files).
- FK-linked tables: outgoing FK to [masterproductregister](masterproductregister.md).
- Second-level FK neighborhood includes: [add_on_product_definition](add_on_product_definition.md), [frequent_products_item](frequent_products_item.md), [installment_plan_configs](installment_plan_configs.md), [master_prod_and_prod_grp_link](master_prod_and_prod_grp_link.md), [masterproductgroups](masterproductgroups.md), [mpr_ipc](mpr_ipc.md), [product_account_configurations](product_account_configurations.md), [product_availability](product_availability.md), [product_group](product_group.md), [subscription_addon_product](subscription_addon_product.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
