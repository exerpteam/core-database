# masterproductregister
Operational table for masterproductregister records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 586 query files; common companions include [products](products.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `definition_key` | Identifier referencing another record in the same table hierarchy. | `int4` | No | No | [masterproductregister](masterproductregister.md) via (`definition_key` -> `id`) | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |
| `product` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `globalid` | Operational field `globalid` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `masterproductregistertype` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | - |
| `masterproductgroup` | Identifier of the related masterproductgroups record used by this row. | `int4` | Yes | No | [masterproductgroups](masterproductgroups.md) via (`masterproductgroup` -> `id`) | - |
| `cached_productname` | Operational field `cached_productname` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `cached_productprice` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `cached_productcostprice` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `cached_producttype` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `cached_external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `info_text` | Business attribute `info_text` used by masterproductregister workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `clearing_house_restriction` | Business attribute `clearing_house_restriction` used by masterproductregister workflows and reporting. | `int4` | No | No | - | - |
| `globally_blocked` | Boolean flag indicating whether the record is blocked from normal use. | `bool` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | Yes | No | - | - |
| `primary_product_group_id` | Identifier of the related product group record used by this row. | `int4` | Yes | No | [product_group](product_group.md) via (`primary_product_group_id` -> `id`) | - |
| `product_account_config_id` | Identifier of the related product account configurations record used by this row. | `int4` | Yes | No | [product_account_configurations](product_account_configurations.md) via (`product_account_config_id` -> `id`) | - |
| `creation_account_config_id` | Identifier of the related product account configurations record used by this row. | `int4` | Yes | No | [product_account_configurations](product_account_configurations.md) via (`creation_account_config_id` -> `id`) | - |
| `prorata_account_config_id` | Identifier of the related product account configurations record used by this row. | `int4` | Yes | No | [product_account_configurations](product_account_configurations.md) via (`prorata_account_config_id` -> `id`) | - |
| `admin_fee_config_id` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `use_contract_template` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `contract_template_id` | Identifier for the related contract template entity used by this record. | `int4` | Yes | No | - | - |
| `last_state_change` | State indicator used to control lifecycle transitions and filtering. | `int8` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `has_future_price_change` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `mapi_selling_points` | Business attribute `mapi_selling_points` used by masterproductregister workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `mapi_rank` | Business attribute `mapi_rank` used by masterproductregister workflows and reporting. | `int4` | Yes | No | - | - |
| `mapi_description` | Business attribute `mapi_description` used by masterproductregister workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `buyout_fee_config_id` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `recurring_clipcard_id` | Identifier for the related recurring clipcard entity used by this record. | `int4` | Yes | No | - | - |
| `recurring_clipcard_clips` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `sale_startup_clipcard` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `sales_commission` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `sales_units` | Operational field `sales_units` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `period_commission` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `print_qr_on_receipt` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `single_use` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `buyout_fee_percentage` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `change_requiredrole` | Business attribute `change_requiredrole` used by masterproductregister workflows and reporting. | `int4` | Yes | No | - | - |
| `clipcard_pack_size` | Business attribute `clipcard_pack_size` used by masterproductregister workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `flat_rate_commission` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `webname` | Business attribute `webname` used by masterproductregister workflows and reporting. | `VARCHAR(1024)` | Yes | No | - | - |
| `use_documentation_settings` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `documentation_settings_id` | Identifier for the related documentation settings entity used by this record. | `int4` | Yes | No | - | [documentation_settings](documentation_settings.md) via (`documentation_settings_id` -> `id`) |
| `family_membership_type` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(20)` | Yes | No | - | - |
| `commissionable` | Monetary value used in financial calculation, settlement, or reporting. | `VARCHAR(20)` | No | No | - | - |

# Relations
- Commonly used with: [products](products.md) (473 query files), [persons](persons.md) (370 query files), [centers](centers.md) (354 query files), [subscriptions](subscriptions.md) (354 query files), [subscription_addon](subscription_addon.md) (338 query files), [subscriptiontypes](subscriptiontypes.md) (242 query files).
- FK-linked tables: outgoing FK to [masterproductgroups](masterproductgroups.md), [masterproductregister](masterproductregister.md), [product_account_configurations](product_account_configurations.md), [product_group](product_group.md); incoming FK from [add_on_product_definition](add_on_product_definition.md), [frequent_products_item](frequent_products_item.md), [installment_plan_configs](installment_plan_configs.md), [master_prod_and_prod_grp_link](master_prod_and_prod_grp_link.md), [masterproductregister](masterproductregister.md), [mpr_ipc](mpr_ipc.md), [product_availability](product_availability.md), [subscription_addon_product](subscription_addon_product.md), [subscription_change_fees](subscription_change_fees.md).
- Second-level FK neighborhood includes: [add_on_to_product_group_link](add_on_to_product_group_link.md), [client_profiles](client_profiles.md), [colour_groups](colour_groups.md), [frequent_products_list](frequent_products_list.md), [installment_plans](installment_plans.md), [product_and_product_group_link](product_and_product_group_link.md), [products](products.md), [roles](roles.md), [subscription_addon](subscription_addon.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
