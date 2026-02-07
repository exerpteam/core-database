# cashregisters
Financial/transactional table for cashregisters records. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 100 query files; common companions include [centers](centers.md), [invoices](invoices.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`) | - | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `1` |
| `cash` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `cash_balance` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `control_device_id` | Identifier of the related control device record. | `text(2147483647)` | Yes | No | - | - | `1001` |
| `asset_accountcenter` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`asset_accountcenter`, `asset_accountid` -> `center`, `id`) | - | `42` |
| `asset_accountid` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`asset_accountcenter`, `asset_accountid` -> `center`, `id`) | - | `42` |
| `reconciliation_accountcenter` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`reconciliation_accountcenter`, `reconciliation_accountid` -> `center`, `id`) | - | `42` |
| `reconciliation_accountid` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`reconciliation_accountcenter`, `reconciliation_accountid` -> `center`, `id`) | - | `42` |
| `rounding_accountcenter` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`rounding_accountcenter`, `rounding_accountid` -> `center`, `id`) | - | `42` |
| `rounding_accountid` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`rounding_accountcenter`, `rounding_accountid` -> `center`, `id`) | - | `42` |
| `error_accountcenter` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`error_accountcenter`, `error_accountid` -> `center`, `id`) | - | `42` |
| `error_accountid` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`error_accountcenter`, `error_accountid` -> `center`, `id`) | - | `42` |
| `payout_accountcenter` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`payout_accountcenter`, `payout_accountid` -> `center`, `id`) | - | `42` |
| `payout_accountid` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`payout_accountcenter`, `payout_accountid` -> `center`, `id`) | - | `42` |
| `bank_accountcenter` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`bank_accountcenter`, `bank_accountid` -> `center`, `id`) | - | `42` |
| `bank_accountid` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`bank_accountcenter`, `bank_accountid` -> `center`, `id`) | - | `42` |
| `cc_asset_accountcenter` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`cc_asset_accountcenter`, `cc_asset_accountid` -> `center`, `id`) | - | `42` |
| `cc_asset_accountid` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`cc_asset_accountcenter`, `cc_asset_accountid` -> `center`, `id`) | - | `42` |
| `default_amount_to_leave` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `cc_payment_method` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `creditcardaccountid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `creditcardaccountpw` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `credit_card_setup` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `inventory` | Foreign key field linking this record to `inventory`. | `int4` | Yes | No | [inventory](inventory.md) via (`inventory` -> `id`) | - | `42` |
| `cc_external_require_trans_no` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `automatic_closing_days` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `fiscalization_plugin_type` | Text field containing descriptive or reference information. | `VARCHAR(20)` | Yes | No | - | - | `Sample value` |
| `fiscalization_plugin_config` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |

# Relations
- Commonly used with: [centers](centers.md) (80 query files), [invoices](invoices.md) (78 query files), [products](products.md) (67 query files), [persons](persons.md) (59 query files), [invoice_lines_mt](invoice_lines_mt.md) (52 query files), [product_group](product_group.md) (51 query files).
- FK-linked tables: outgoing FK to [accounts](accounts.md), [centers](centers.md), [inventory](inventory.md); incoming FK from [cash_register_log](cash_register_log.md), [cashregistertransactions](cashregistertransactions.md), [credit_notes](credit_notes.md), [invoices](invoices.md), [vending_machine](vending_machine.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [account_vat_type_group](account_vat_type_group.md), [accountingperiods](accountingperiods.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [area_centers](area_centers.md), [bills](bills.md), [bookings](bookings.md), [cashregisterreports](cashregisterreports.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
