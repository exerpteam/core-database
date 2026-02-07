# account_trans
Financial/transactional table for account trans records. It is typically used where rows are center-scoped; it appears in approximately 494 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [accountingperiods](accountingperiods.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [accountingperiods](accountingperiods.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `trans_type` | Classification code describing the trans type category (for example: 0, AR, Account Payable, Account Receivable). | `int4` | No | No | - | - |
| `trans_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `debit_accountcenter` | Center component of the composite reference to the related debit account record. | `int4` | No | No | [accounts](accounts.md) via (`debit_accountcenter`, `debit_accountid` -> `center`, `id`) | - |
| `debit_accountid` | Identifier component of the composite reference to the related debit account record. | `int4` | No | No | [accounts](accounts.md) via (`debit_accountcenter`, `debit_accountid` -> `center`, `id`) | - |
| `credit_accountcenter` | Center component of the composite reference to the related credit account record. | `int4` | No | No | [accounts](accounts.md) via (`credit_accountcenter`, `credit_accountid` -> `center`, `id`) | - |
| `credit_accountid` | Identifier component of the composite reference to the related credit account record. | `int4` | No | No | [accounts](accounts.md) via (`credit_accountcenter`, `credit_accountid` -> `center`, `id`) | - |
| `main_transcenter` | Center component of the composite reference to the related main trans record. | `int4` | Yes | No | [account_trans](account_trans.md) via (`main_transcenter`, `main_transid`, `main_transsubid` -> `center`, `id`, `subid`) | - |
| `main_transid` | Identifier component of the composite reference to the related main trans record. | `int4` | Yes | No | [account_trans](account_trans.md) via (`main_transcenter`, `main_transid`, `main_transsubid` -> `center`, `id`, `subid`) | - |
| `main_transsubid` | Identifier referencing another record in the same table hierarchy. | `int4` | Yes | No | [account_trans](account_trans.md) via (`main_transcenter`, `main_transid`, `main_transsubid` -> `center`, `id`, `subid`) | - |
| `origin_transcenter` | Center component of the composite reference to the related origin trans record. | `int4` | Yes | No | [account_trans](account_trans.md) via (`origin_transcenter`, `origin_transid`, `origin_transsubid` -> `center`, `id`, `subid`) | - |
| `origin_transid` | Identifier component of the composite reference to the related origin trans record. | `int4` | Yes | No | [account_trans](account_trans.md) via (`origin_transcenter`, `origin_transid`, `origin_transsubid` -> `center`, `id`, `subid`) | - |
| `origin_transsubid` | Identifier referencing another record in the same table hierarchy. | `int4` | Yes | No | [account_trans](account_trans.md) via (`origin_transcenter`, `origin_transid`, `origin_transsubid` -> `center`, `id`, `subid`) | - |
| `text` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | No | No | - | - |
| `transferred` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `export_file` | Business attribute `export_file` used by account trans workflows and reporting. | `int4` | Yes | No | - | - |
| `aggregated_transaction_center` | Center component of the composite reference to the related aggregated transaction record. | `int4` | Yes | No | [aggregated_transactions](aggregated_transactions.md) via (`aggregated_transaction_center`, `aggregated_transaction_id` -> `center`, `id`) | - |
| `aggregated_transaction_id` | Identifier component of the composite reference to the related aggregated transaction record. | `int4` | Yes | No | [aggregated_transactions](aggregated_transactions.md) via (`aggregated_transaction_center`, `aggregated_transaction_id` -> `center`, `id`) | - |
| `vat_type_center` | Center component of the composite reference to the related vat type record. | `int4` | Yes | No | [vat_types](vat_types.md) via (`vat_type_center`, `vat_type_id` -> `center`, `id`) | - |
| `vat_type_id` | Identifier component of the composite reference to the related vat type record. | `int4` | Yes | No | [vat_types](vat_types.md) via (`vat_type_center`, `vat_type_id` -> `center`, `id`) | - |
| `info_type` | Classification code describing the info type category (for example: API, AR, ARReason, CashRegister). | `int4` | No | No | - | - |
| `info` | Operational field `info` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `debit_transaction_center` | Center component of the composite reference to the related debit transaction record. | `int4` | Yes | No | - | - |
| `debit_transaction_id` | Identifier component of the composite reference to the related debit transaction record. | `int4` | Yes | No | - | - |
| `debit_transaction_subid` | Business attribute `debit_transaction_subid` used by account trans workflows and reporting. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (381 query files), [centers](centers.md) (378 query files), [ar_trans](ar_trans.md) (353 query files), [account_receivables](account_receivables.md) (312 query files), [accounts](accounts.md) (274 query files), [products](products.md) (196 query files).
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [vat_types](vat_types.md); incoming FK from [account_trans](account_trans.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [cashregistertransactions](cashregistertransactions.md), [credit_note_line_vat_at_link](credit_note_line_vat_at_link.md), [credit_note_lines_mt](credit_note_lines_mt.md), [deferrals](deferrals.md), [deliverylines_vat_at_link](deliverylines_vat_at_link.md), [gift_card_usages](gift_card_usages.md), [inventory_trans](inventory_trans.md), [invoice_lines_mt](invoice_lines_mt.md), [invoicelines_vat_at_link](invoicelines_vat_at_link.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_vat_type_group](account_vat_type_group.md), [account_vat_type_link](account_vat_type_link.md), [ar_trans](ar_trans.md), [bills](bills.md), [bundle_campaign_usages](bundle_campaign_usages.md), [card_clip_usages](card_clip_usages.md), [cashregisterreports](cashregisterreports.md), [cashregisters](cashregisters.md), [centers](centers.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
