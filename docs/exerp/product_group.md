# product_group
Operational table for product group records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 918 query files; common companions include [products](products.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `top_node_id` | Identifier of the related top node record. | `int4` | Yes | No | - | - | `1001` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `parent_product_group_id` | Identifier of the related parent product group record. | `int4` | Yes | No | - | - | `1001` |
| `dimension_product_group_id` | Identifier of the related dimension product group record. | `int4` | Yes | No | - | - | `1001` |
| `show_in_shop` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `product_account_config_id` | Foreign key field linking this record to `product_account_configurations`. | `int4` | Yes | No | [product_account_configurations](product_account_configurations.md) via (`product_account_config_id` -> `id`) | - | `1001` |
| `colour_group_id` | Foreign key field linking this record to `colour_groups`. | `int4` | Yes | No | [colour_groups](colour_groups.md) via (`colour_group_id` -> `id`) | - | `1001` |
| `ranking` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `in_subscription_sales` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `hide_in_report_parameters` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `exclude_from_member_count` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `exclude_from_product_cleaning` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `client_profile_id` | Foreign key field linking this record to `client_profiles`. | `int4` | Yes | No | [client_profiles](client_profiles.md) via (`client_profile_id` -> `id`) | - | `1001` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - | `EXT-1001` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |
| `single_product_in_basket` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `show_on_web` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `installment_plans_enabled` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |

# Relations
- Commonly used with: [products](products.md) (828 query files), [centers](centers.md) (671 query files), [persons](persons.md) (661 query files), [subscriptions](subscriptions.md) (524 query files), [product_and_product_group_link](product_and_product_group_link.md) (436 query files), [subscriptiontypes](subscriptiontypes.md) (358 query files).
- FK-linked tables: outgoing FK to [client_profiles](client_profiles.md), [colour_groups](colour_groups.md), [product_account_configurations](product_account_configurations.md); incoming FK from [add_on_to_product_group_link](add_on_to_product_group_link.md), [master_prod_and_prod_grp_link](master_prod_and_prod_grp_link.md), [masterproductregister](masterproductregister.md), [product_and_product_group_link](product_and_product_group_link.md), [products](products.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [add_on_product_definition](add_on_product_definition.md), [centers](centers.md), [clipcardtypes](clipcardtypes.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery_lines_mt](delivery_lines_mt.md), [frequent_products_item](frequent_products_item.md), [frequent_products_list](frequent_products_list.md), [gift_cards](gift_cards.md), [installment_plan_configs](installment_plan_configs.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
