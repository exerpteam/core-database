# subscription_change_fees
Stores subscription-related data, including lifecycle and financial context. It is typically used where lifecycle state codes are present; it appears in approximately 3 query files; common companions include [masterproductregister](masterproductregister.md), [product_group](product_group.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `subscr_type_from` | Identifier of the related masterproductregister record used by this row. | `int4` | Yes | No | [masterproductregister](masterproductregister.md) via (`subscr_type_from` -> `id`) | - |
| `subscr_type_to` | Identifier of the related masterproductregister record used by this row. | `int4` | Yes | No | [masterproductregister](masterproductregister.md) via (`subscr_type_to` -> `id`) | - |
| `change_fee_product` | Identifier of the related masterproductregister record used by this row. | `int4` | No | No | [masterproductregister](masterproductregister.md) via (`change_fee_product` -> `id`) | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `text(2147483647)` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `created` | Operational field `created` used in query filtering and reporting transformations. | `TIMESTAMP` | No | No | - | - |
| `modified` | Business attribute `modified` used by subscription change fees workflows and reporting. | `TIMESTAMP` | No | No | - | - |
| `deleted` | Operational field `deleted` used in query filtering and reporting transformations. | `TIMESTAMP` | Yes | No | - | - |
| `version` | Operational field `version` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `change_fee_percentage` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `use_remaining_contract_value` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |

# Relations
- Commonly used with: [masterproductregister](masterproductregister.md) (3 query files), [product_group](product_group.md) (2 query files).
- FK-linked tables: outgoing FK to [masterproductregister](masterproductregister.md).
- Second-level FK neighborhood includes: [add_on_product_definition](add_on_product_definition.md), [frequent_products_item](frequent_products_item.md), [installment_plan_configs](installment_plan_configs.md), [master_prod_and_prod_grp_link](master_prod_and_prod_grp_link.md), [masterproductgroups](masterproductgroups.md), [mpr_ipc](mpr_ipc.md), [product_account_configurations](product_account_configurations.md), [product_availability](product_availability.md), [product_group](product_group.md), [subscription_addon_product](subscription_addon_product.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
