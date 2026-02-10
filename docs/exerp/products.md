# products
Operational table for products records in the Exerp schema. It is typically used where rows are center-scoped; change-tracking timestamps are available; it appears in approximately 2749 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `blocked` | Boolean flag indicating whether the record is blocked from normal use. | `bool` | No | No | - | - |
| `ptype` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | [products_ptype](../master%20tables/products_ptype.md) |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `coment` | Operational field `coment` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `income_accountcenter` | Center component of the composite reference to the related income account record. | `int4` | Yes | No | [accounts](accounts.md) via (`income_accountcenter`, `income_accountid` -> `center`, `id`) | - |
| `income_accountid` | Identifier component of the composite reference to the related income account record. | `int4` | Yes | No | [accounts](accounts.md) via (`income_accountcenter`, `income_accountid` -> `center`, `id`) | - |
| `expense_accountcenter` | Center component of the composite reference to the related expense account record. | `int4` | Yes | No | [accounts](accounts.md) via (`expense_accountcenter`, `expense_accountid` -> `center`, `id`) | - |
| `expense_accountid` | Identifier component of the composite reference to the related expense account record. | `int4` | Yes | No | [accounts](accounts.md) via (`expense_accountcenter`, `expense_accountid` -> `center`, `id`) | - |
| `refund_accountcenter` | Center component of the composite reference to the related refund account record. | `int4` | Yes | No | [accounts](accounts.md) via (`refund_accountcenter`, `refund_accountid` -> `center`, `id`) | - |
| `refund_accountid` | Identifier component of the composite reference to the related refund account record. | `int4` | Yes | No | [accounts](accounts.md) via (`refund_accountcenter`, `refund_accountid` -> `center`, `id`) | - |
| `price` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `min_price` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `cost_price` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `requiredrole` | Identifier of the related roles record used by this row. | `int4` | Yes | No | [roles](roles.md) via (`requiredrole` -> `id`) | - |
| `globalid` | Operational field `globalid` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `max_buy_qty` | Business attribute `max_buy_qty` used by products workflows and reporting. | `int4` | Yes | No | - | - |
| `max_buy_qty_period` | Business attribute `max_buy_qty_period` used by products workflows and reporting. | `int4` | Yes | No | - | - |
| `max_buy_qty_period_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `needs_privilege` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `show_in_sale` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `returnable` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `show_on_web` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `show_on_mobile_api` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `primary_product_group_id` | Identifier of the related product group record used by this row. | `int4` | Yes | No | [product_group](product_group.md) via (`primary_product_group_id` -> `id`) | - |
| `product_account_config_id` | Identifier of the related product account configurations record used by this row. | `int4` | Yes | No | [product_account_configurations](product_account_configurations.md) via (`product_account_config_id` -> `id`) | - |
| `override_price_and_text_role` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `ipc_available` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `restriction_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `last_recount_date` | Business date used for scheduling, validity, or reporting cutoffs. | `int8` | Yes | No | - | - |
| `mapi_selling_points` | Business attribute `mapi_selling_points` used by products workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `mapi_rank` | Business attribute `mapi_rank` used by products workflows and reporting. | `int4` | Yes | No | - | - |
| `mapi_description` | Business attribute `mapi_description` used by products workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `sales_commission` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `sales_units` | Operational field `sales_units` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `sold_outside_home_center` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `period_commission` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `print_qr_on_receipt` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `single_use` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `assigned_staff_group` | Reference component identifying the staff member assigned to handle the record. | `int4` | Yes | No | - | - |
| `flat_rate_commission` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `webname` | Business attribute `webname` used by products workflows and reporting. | `VARCHAR(1024)` | Yes | No | - | - |
| `commissionable` | Monetary value used in financial calculation, settlement, or reporting. | `VARCHAR(20)` | No | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (2203 query files), [centers](centers.md) (1880 query files), [subscriptions](subscriptions.md) (1846 query files), [subscriptiontypes](subscriptiontypes.md) (1105 query files), [person_ext_attrs](person_ext_attrs.md) (924 query files), [product_group](product_group.md) (828 query files).
- FK-linked tables: outgoing FK to [accounts](accounts.md), [centers](centers.md), [product_account_configurations](product_account_configurations.md), [product_group](product_group.md), [roles](roles.md); incoming FK from [clipcardtypes](clipcardtypes.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery_lines_mt](delivery_lines_mt.md), [gift_cards](gift_cards.md), [inventory_trans](inventory_trans.md), [invoice_lines_mt](invoice_lines_mt.md), [lease_products](lease_products.md), [product_and_product_group_link](product_and_product_group_link.md), [subscription_sales](subscription_sales.md), [subscriptions](subscriptions.md), [subscriptiontypes](subscriptiontypes.md), [vending_machine_slide](vending_machine_slide.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [account_vat_type_group](account_vat_type_group.md), [accountingperiods](accountingperiods.md), [add_on_to_product_group_link](add_on_to_product_group_link.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bookings](bookings.md), [bundle_campaign_usages](bundle_campaign_usages.md), [campaign_codes](campaign_codes.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; change timestamps support incremental extraction and reconciliation.
