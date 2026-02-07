# masterproductregister
Operational table for masterproductregister records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 586 query files; common companions include [products](products.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `definition_key` | Foreign key field linking this record to `masterproductregister`. | `int4` | No | No | [masterproductregister](masterproductregister.md) via (`definition_key` -> `id`) | - | `42` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - | `1001` |
| `product` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `masterproductregistertype` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `masterproductgroup` | Foreign key field linking this record to `masterproductgroups`. | `int4` | Yes | No | [masterproductgroups](masterproductgroups.md) via (`masterproductgroup` -> `id`) | - | `42` |
| `cached_productname` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `cached_productprice` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `cached_productcostprice` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `cached_producttype` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `cached_external_id` | Identifier of the related cached external record. | `text(2147483647)` | Yes | No | - | - | `EXT-1001` |
| `info_text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `clearing_house_restriction` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `globally_blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | Yes | No | - | - | `1` |
| `primary_product_group_id` | Foreign key field linking this record to `product_group`. | `int4` | Yes | No | [product_group](product_group.md) via (`primary_product_group_id` -> `id`) | - | `1001` |
| `product_account_config_id` | Foreign key field linking this record to `product_account_configurations`. | `int4` | Yes | No | [product_account_configurations](product_account_configurations.md) via (`product_account_config_id` -> `id`) | - | `1001` |
| `creation_account_config_id` | Foreign key field linking this record to `product_account_configurations`. | `int4` | Yes | No | [product_account_configurations](product_account_configurations.md) via (`creation_account_config_id` -> `id`) | - | `1001` |
| `prorata_account_config_id` | Foreign key field linking this record to `product_account_configurations`. | `int4` | Yes | No | [product_account_configurations](product_account_configurations.md) via (`prorata_account_config_id` -> `id`) | - | `1001` |
| `admin_fee_config_id` | Identifier of the related admin fee config record. | `int4` | Yes | No | - | - | `1001` |
| `use_contract_template` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `contract_template_id` | Identifier of the related contract template record. | `int4` | Yes | No | - | - | `1001` |
| `last_state_change` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |
| `has_future_price_change` | Boolean flag indicating presence of future price change. | `bool` | No | No | - | - | `true` |
| `mapi_selling_points` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `mapi_rank` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `mapi_description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `buyout_fee_config_id` | Identifier of the related buyout fee config record. | `int4` | Yes | No | - | - | `1001` |
| `recurring_clipcard_id` | Identifier of the related recurring clipcard record. | `int4` | Yes | No | - | - | `1001` |
| `recurring_clipcard_clips` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `sale_startup_clipcard` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `sales_commission` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `sales_units` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `period_commission` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `print_qr_on_receipt` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `single_use` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `buyout_fee_percentage` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `change_requiredrole` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `clipcard_pack_size` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `flat_rate_commission` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `webname` | Text field containing descriptive or reference information. | `VARCHAR(1024)` | Yes | No | - | - | `Example Name` |
| `use_documentation_settings` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `documentation_settings_id` | Identifier of the related documentation settings record. | `int4` | Yes | No | - | [documentation_settings](documentation_settings.md) via (`documentation_settings_id` -> `id`) | `1001` |
| `family_membership_type` | Text field containing descriptive or reference information. | `VARCHAR(20)` | Yes | No | - | - | `Sample value` |
| `commissionable` | Text field containing descriptive or reference information. | `VARCHAR(20)` | No | No | - | - | `Sample value` |

# Relations
- Commonly used with: [products](products.md) (473 query files), [persons](persons.md) (370 query files), [centers](centers.md) (354 query files), [subscriptions](subscriptions.md) (354 query files), [subscription_addon](subscription_addon.md) (338 query files), [subscriptiontypes](subscriptiontypes.md) (242 query files).
- FK-linked tables: outgoing FK to [masterproductgroups](masterproductgroups.md), [masterproductregister](masterproductregister.md), [product_account_configurations](product_account_configurations.md), [product_group](product_group.md); incoming FK from [add_on_product_definition](add_on_product_definition.md), [frequent_products_item](frequent_products_item.md), [installment_plan_configs](installment_plan_configs.md), [master_prod_and_prod_grp_link](master_prod_and_prod_grp_link.md), [masterproductregister](masterproductregister.md), [mpr_ipc](mpr_ipc.md), [product_availability](product_availability.md), [subscription_addon_product](subscription_addon_product.md), [subscription_change_fees](subscription_change_fees.md).
- Second-level FK neighborhood includes: [add_on_to_product_group_link](add_on_to_product_group_link.md), [client_profiles](client_profiles.md), [colour_groups](colour_groups.md), [frequent_products_list](frequent_products_list.md), [installment_plans](installment_plans.md), [product_and_product_group_link](product_and_product_group_link.md), [products](products.md), [roles](roles.md), [subscription_addon](subscription_addon.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
