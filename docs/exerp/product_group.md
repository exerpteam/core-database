# product_group
Operational table for product group records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 918 query files; common companions include [products](products.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `top_node_id` | Identifier of the top hierarchy node used to organize scoped records. | `int4` | Yes | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `parent_product_group_id` | Identifier for the related parent product group entity used by this record. | `int4` | Yes | No | - | - |
| `dimension_product_group_id` | Identifier for the related dimension product group entity used by this record. | `int4` | Yes | No | - | - |
| `show_in_shop` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `product_account_config_id` | Identifier of the related product account configurations record used by this row. | `int4` | Yes | No | [product_account_configurations](product_account_configurations.md) via (`product_account_config_id` -> `id`) | - |
| `colour_group_id` | Identifier of the related colour groups record used by this row. | `int4` | Yes | No | [colour_groups](colour_groups.md) via (`colour_group_id` -> `id`) | - |
| `ranking` | Operational field `ranking` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `in_subscription_sales` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `hide_in_report_parameters` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `exclude_from_member_count` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `exclude_from_product_cleaning` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `client_profile_id` | Identifier of the related client profiles record used by this row. | `int4` | Yes | No | [client_profiles](client_profiles.md) via (`client_profile_id` -> `id`) | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `single_product_in_basket` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `show_on_web` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `installment_plans_enabled` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |

# Relations
- Commonly used with: [products](products.md) (828 query files), [centers](centers.md) (671 query files), [persons](persons.md) (661 query files), [subscriptions](subscriptions.md) (524 query files), [product_and_product_group_link](product_and_product_group_link.md) (436 query files), [subscriptiontypes](subscriptiontypes.md) (358 query files).
- FK-linked tables: outgoing FK to [client_profiles](client_profiles.md), [colour_groups](colour_groups.md), [product_account_configurations](product_account_configurations.md); incoming FK from [add_on_to_product_group_link](add_on_to_product_group_link.md), [master_prod_and_prod_grp_link](master_prod_and_prod_grp_link.md), [masterproductregister](masterproductregister.md), [product_and_product_group_link](product_and_product_group_link.md), [products](products.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [add_on_product_definition](add_on_product_definition.md), [centers](centers.md), [clipcardtypes](clipcardtypes.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery_lines_mt](delivery_lines_mt.md), [frequent_products_item](frequent_products_item.md), [frequent_products_list](frequent_products_list.md), [gift_cards](gift_cards.md), [installment_plan_configs](installment_plan_configs.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
