# deferrals
Operational table for deferrals records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `center` | Center identifier associated with the record. | `int4` | No | No | - | [centers](centers.md) via (`center` -> `id`) | `101` |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - | `1738281600000` |
| `defer_acc_trans_center` | Foreign key field linking this record to `account_trans`. | `int4` | No | No | [account_trans](account_trans.md) via (`defer_acc_trans_center`, `defer_acc_trans_id`, `defer_acc_trans_subid` -> `center`, `id`, `subid`) | - | `101` |
| `defer_acc_trans_id` | Foreign key field linking this record to `account_trans`. | `int4` | No | No | [account_trans](account_trans.md) via (`defer_acc_trans_center`, `defer_acc_trans_id`, `defer_acc_trans_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `defer_acc_trans_subid` | Foreign key field linking this record to `account_trans`. | `int4` | No | No | [account_trans](account_trans.md) via (`defer_acc_trans_center`, `defer_acc_trans_id`, `defer_acc_trans_subid` -> `center`, `id`, `subid`) | - | `1` |
| `revenue_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `reversal_entry_time` | Epoch timestamp for reversal entry. | `int8` | Yes | No | - | - | `1738281600000` |
| `reversal_acc_trans_center` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`reversal_acc_trans_center`, `reversal_acc_trans_id`, `reversal_acc_trans_subid` -> `center`, `id`, `subid`) | - | `101` |
| `reversal_acc_trans_id` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`reversal_acc_trans_center`, `reversal_acc_trans_id`, `reversal_acc_trans_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `reversal_acc_trans_subid` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`reversal_acc_trans_center`, `reversal_acc_trans_id`, `reversal_acc_trans_subid` -> `center`, `id`, `subid`) | - | `1` |

# Relations
- FK-linked tables: outgoing FK to [account_trans](account_trans.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [cashregistertransactions](cashregistertransactions.md), [credit_note_line_vat_at_link](credit_note_line_vat_at_link.md), [credit_note_lines_mt](credit_note_lines_mt.md), [deliverylines_vat_at_link](deliverylines_vat_at_link.md), [gift_card_usages](gift_card_usages.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
