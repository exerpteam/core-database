# cashregisters
Financial/transactional table for cashregisters records. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 100 query files; common companions include [centers](centers.md), [invoices](invoices.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `text(2147483647)` | No | No | - | - |
| `cash` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `blocked` | Boolean flag indicating whether the record is blocked from normal use. | `bool` | No | No | - | - |
| `cash_balance` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `control_device_id` | Identifier for the related control device entity used by this record. | `text(2147483647)` | Yes | No | - | - |
| `asset_accountcenter` | Center component of the composite reference to the related asset account record. | `int4` | Yes | No | [accounts](accounts.md) via (`asset_accountcenter`, `asset_accountid` -> `center`, `id`) | - |
| `asset_accountid` | Identifier component of the composite reference to the related asset account record. | `int4` | Yes | No | [accounts](accounts.md) via (`asset_accountcenter`, `asset_accountid` -> `center`, `id`) | - |
| `reconciliation_accountcenter` | Center component of the composite reference to the related reconciliation account record. | `int4` | Yes | No | [accounts](accounts.md) via (`reconciliation_accountcenter`, `reconciliation_accountid` -> `center`, `id`) | - |
| `reconciliation_accountid` | Identifier component of the composite reference to the related reconciliation account record. | `int4` | Yes | No | [accounts](accounts.md) via (`reconciliation_accountcenter`, `reconciliation_accountid` -> `center`, `id`) | - |
| `rounding_accountcenter` | Center component of the composite reference to the related rounding account record. | `int4` | Yes | No | [accounts](accounts.md) via (`rounding_accountcenter`, `rounding_accountid` -> `center`, `id`) | - |
| `rounding_accountid` | Identifier component of the composite reference to the related rounding account record. | `int4` | Yes | No | [accounts](accounts.md) via (`rounding_accountcenter`, `rounding_accountid` -> `center`, `id`) | - |
| `error_accountcenter` | Center component of the composite reference to the related error account record. | `int4` | Yes | No | [accounts](accounts.md) via (`error_accountcenter`, `error_accountid` -> `center`, `id`) | - |
| `error_accountid` | Identifier component of the composite reference to the related error account record. | `int4` | Yes | No | [accounts](accounts.md) via (`error_accountcenter`, `error_accountid` -> `center`, `id`) | - |
| `payout_accountcenter` | Center component of the composite reference to the related payout account record. | `int4` | Yes | No | [accounts](accounts.md) via (`payout_accountcenter`, `payout_accountid` -> `center`, `id`) | - |
| `payout_accountid` | Identifier component of the composite reference to the related payout account record. | `int4` | Yes | No | [accounts](accounts.md) via (`payout_accountcenter`, `payout_accountid` -> `center`, `id`) | - |
| `bank_accountcenter` | Center component of the composite reference to the related bank account record. | `int4` | Yes | No | [accounts](accounts.md) via (`bank_accountcenter`, `bank_accountid` -> `center`, `id`) | - |
| `bank_accountid` | Identifier component of the composite reference to the related bank account record. | `int4` | Yes | No | [accounts](accounts.md) via (`bank_accountcenter`, `bank_accountid` -> `center`, `id`) | - |
| `cc_asset_accountcenter` | Center component of the composite reference to the related cc asset account record. | `int4` | Yes | No | [accounts](accounts.md) via (`cc_asset_accountcenter`, `cc_asset_accountid` -> `center`, `id`) | - |
| `cc_asset_accountid` | Identifier component of the composite reference to the related cc asset account record. | `int4` | Yes | No | [accounts](accounts.md) via (`cc_asset_accountcenter`, `cc_asset_accountid` -> `center`, `id`) | - |
| `default_amount_to_leave` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `cc_payment_method` | Business attribute `cc_payment_method` used by cashregisters workflows and reporting. | `int4` | Yes | No | - | - |
| `creditcardaccountid` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `creditcardaccountpw` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `credit_card_setup` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `inventory` | Identifier of the related inventory record used by this row. | `int4` | Yes | No | [inventory](inventory.md) via (`inventory` -> `id`) | - |
| `cc_external_require_trans_no` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `automatic_closing_days` | Business attribute `automatic_closing_days` used by cashregisters workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `fiscalization_plugin_type` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(20)` | Yes | No | - | - |
| `fiscalization_plugin_config` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (80 query files), [invoices](invoices.md) (78 query files), [products](products.md) (67 query files), [persons](persons.md) (59 query files), [invoice_lines_mt](invoice_lines_mt.md) (52 query files), [product_group](product_group.md) (51 query files).
- FK-linked tables: outgoing FK to [accounts](accounts.md), [centers](centers.md), [inventory](inventory.md); incoming FK from [cash_register_log](cash_register_log.md), [cashregistertransactions](cashregistertransactions.md), [credit_notes](credit_notes.md), [invoices](invoices.md), [vending_machine](vending_machine.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [account_vat_type_group](account_vat_type_group.md), [accountingperiods](accountingperiods.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [area_centers](area_centers.md), [bills](bills.md), [bookings](bookings.md), [cashregisterreports](cashregisterreports.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
