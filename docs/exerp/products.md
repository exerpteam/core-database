# products
Operational table for products records in the Exerp schema. It is typically used where rows are center-scoped; change-tracking timestamps are available; it appears in approximately 2749 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`) | - | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `ptype` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `coment` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - | `EXT-1001` |
| `income_accountcenter` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`income_accountcenter`, `income_accountid` -> `center`, `id`) | - | `42` |
| `income_accountid` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`income_accountcenter`, `income_accountid` -> `center`, `id`) | - | `42` |
| `expense_accountcenter` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`expense_accountcenter`, `expense_accountid` -> `center`, `id`) | - | `42` |
| `expense_accountid` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`expense_accountcenter`, `expense_accountid` -> `center`, `id`) | - | `42` |
| `refund_accountcenter` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`refund_accountcenter`, `refund_accountid` -> `center`, `id`) | - | `42` |
| `refund_accountid` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`refund_accountcenter`, `refund_accountid` -> `center`, `id`) | - | `42` |
| `price` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `min_price` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `cost_price` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `requiredrole` | Foreign key field linking this record to `roles`. | `int4` | Yes | No | [roles](roles.md) via (`requiredrole` -> `id`) | - | `42` |
| `globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `max_buy_qty` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `max_buy_qty_period` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `max_buy_qty_period_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `needs_privilege` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `show_in_sale` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `returnable` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `show_on_web` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `show_on_mobile_api` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `primary_product_group_id` | Foreign key field linking this record to `product_group`. | `int4` | Yes | No | [product_group](product_group.md) via (`primary_product_group_id` -> `id`) | - | `1001` |
| `product_account_config_id` | Foreign key field linking this record to `product_account_configurations`. | `int4` | Yes | No | [product_account_configurations](product_account_configurations.md) via (`product_account_config_id` -> `id`) | - | `1001` |
| `override_price_and_text_role` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `ipc_available` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |
| `restriction_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `last_recount_date` | Date for last recount. | `int8` | Yes | No | - | - | `42` |
| `mapi_selling_points` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `mapi_rank` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `mapi_description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `sales_commission` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `sales_units` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `sold_outside_home_center` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `period_commission` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `print_qr_on_receipt` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `single_use` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `assigned_staff_group` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `flat_rate_commission` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `webname` | Text field containing descriptive or reference information. | `VARCHAR(1024)` | Yes | No | - | - | `Example Name` |
| `commissionable` | Text field containing descriptive or reference information. | `VARCHAR(20)` | No | No | - | - | `Sample value` |

# Relations
- Commonly used with: [persons](persons.md) (2203 query files), [centers](centers.md) (1880 query files), [subscriptions](subscriptions.md) (1846 query files), [subscriptiontypes](subscriptiontypes.md) (1105 query files), [person_ext_attrs](person_ext_attrs.md) (924 query files), [product_group](product_group.md) (828 query files).
- FK-linked tables: outgoing FK to [accounts](accounts.md), [centers](centers.md), [product_account_configurations](product_account_configurations.md), [product_group](product_group.md), [roles](roles.md); incoming FK from [clipcardtypes](clipcardtypes.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery_lines_mt](delivery_lines_mt.md), [gift_cards](gift_cards.md), [inventory_trans](inventory_trans.md), [invoice_lines_mt](invoice_lines_mt.md), [lease_products](lease_products.md), [product_and_product_group_link](product_and_product_group_link.md), [subscription_sales](subscription_sales.md), [subscriptions](subscriptions.md), [subscriptiontypes](subscriptiontypes.md), [vending_machine_slide](vending_machine_slide.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [account_vat_type_group](account_vat_type_group.md), [accountingperiods](accountingperiods.md), [add_on_to_product_group_link](add_on_to_product_group_link.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bookings](bookings.md), [bundle_campaign_usages](bundle_campaign_usages.md), [campaign_codes](campaign_codes.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; change timestamps support incremental extraction and reconciliation.
