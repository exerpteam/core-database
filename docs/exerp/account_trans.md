# account_trans
Financial/transactional table for account trans records. It is typically used where rows are center-scoped; it appears in approximately 494 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [accountingperiods](accountingperiods.md) via (`center`, `id` -> `center`, `id`) | - | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [accountingperiods](accountingperiods.md) via (`center`, `id` -> `center`, `id`) | - | `1001` |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - | `1` |
| `trans_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `trans_time` | Epoch timestamp for trans. | `int8` | No | No | - | - | `1738281600000` |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - | `1738281600000` |
| `amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `debit_accountcenter` | Foreign key field linking this record to `accounts`. | `int4` | No | No | [accounts](accounts.md) via (`debit_accountcenter`, `debit_accountid` -> `center`, `id`) | - | `42` |
| `debit_accountid` | Foreign key field linking this record to `accounts`. | `int4` | No | No | [accounts](accounts.md) via (`debit_accountcenter`, `debit_accountid` -> `center`, `id`) | - | `42` |
| `credit_accountcenter` | Foreign key field linking this record to `accounts`. | `int4` | No | No | [accounts](accounts.md) via (`credit_accountcenter`, `credit_accountid` -> `center`, `id`) | - | `42` |
| `credit_accountid` | Foreign key field linking this record to `accounts`. | `int4` | No | No | [accounts](accounts.md) via (`credit_accountcenter`, `credit_accountid` -> `center`, `id`) | - | `42` |
| `main_transcenter` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`main_transcenter`, `main_transid`, `main_transsubid` -> `center`, `id`, `subid`) | - | `42` |
| `main_transid` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`main_transcenter`, `main_transid`, `main_transsubid` -> `center`, `id`, `subid`) | - | `42` |
| `main_transsubid` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`main_transcenter`, `main_transid`, `main_transsubid` -> `center`, `id`, `subid`) | - | `42` |
| `origin_transcenter` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`origin_transcenter`, `origin_transid`, `origin_transsubid` -> `center`, `id`, `subid`) | - | `42` |
| `origin_transid` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`origin_transcenter`, `origin_transid`, `origin_transsubid` -> `center`, `id`, `subid`) | - | `42` |
| `origin_transsubid` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`origin_transcenter`, `origin_transid`, `origin_transsubid` -> `center`, `id`, `subid`) | - | `42` |
| `text` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `transferred` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `export_file` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `aggregated_transaction_center` | Foreign key field linking this record to `aggregated_transactions`. | `int4` | Yes | No | [aggregated_transactions](aggregated_transactions.md) via (`aggregated_transaction_center`, `aggregated_transaction_id` -> `center`, `id`) | - | `101` |
| `aggregated_transaction_id` | Foreign key field linking this record to `aggregated_transactions`. | `int4` | Yes | No | [aggregated_transactions](aggregated_transactions.md) via (`aggregated_transaction_center`, `aggregated_transaction_id` -> `center`, `id`) | - | `1001` |
| `vat_type_center` | Foreign key field linking this record to `vat_types`. | `int4` | Yes | No | [vat_types](vat_types.md) via (`vat_type_center`, `vat_type_id` -> `center`, `id`) | - | `101` |
| `vat_type_id` | Foreign key field linking this record to `vat_types`. | `int4` | Yes | No | [vat_types](vat_types.md) via (`vat_type_center`, `vat_type_id` -> `center`, `id`) | - | `1001` |
| `info_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `info` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `debit_transaction_center` | Center part of the reference to related debit transaction data. | `int4` | Yes | No | - | - | `101` |
| `debit_transaction_id` | Identifier of the related debit transaction record. | `int4` | Yes | No | - | - | `1001` |
| `debit_transaction_subid` | Sub-identifier for related debit transaction detail rows. | `int4` | Yes | No | - | - | `1` |

# Relations
- Commonly used with: [persons](persons.md) (381 query files), [centers](centers.md) (378 query files), [ar_trans](ar_trans.md) (353 query files), [account_receivables](account_receivables.md) (312 query files), [accounts](accounts.md) (274 query files), [products](products.md) (196 query files).
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [vat_types](vat_types.md); incoming FK from [account_trans](account_trans.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [cashregistertransactions](cashregistertransactions.md), [credit_note_line_vat_at_link](credit_note_line_vat_at_link.md), [credit_note_lines_mt](credit_note_lines_mt.md), [deferrals](deferrals.md), [deliverylines_vat_at_link](deliverylines_vat_at_link.md), [gift_card_usages](gift_card_usages.md), [inventory_trans](inventory_trans.md), [invoice_lines_mt](invoice_lines_mt.md), [invoicelines_vat_at_link](invoicelines_vat_at_link.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_vat_type_group](account_vat_type_group.md), [account_vat_type_link](account_vat_type_link.md), [ar_trans](ar_trans.md), [bills](bills.md), [bundle_campaign_usages](bundle_campaign_usages.md), [card_clip_usages](card_clip_usages.md), [cashregisterreports](cashregisterreports.md), [cashregisters](cashregisters.md), [centers](centers.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
