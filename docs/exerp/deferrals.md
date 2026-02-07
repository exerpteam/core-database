# deferrals
Operational table for deferrals records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `center` | Operational field `center` used in query filtering and reporting transformations. | `int4` | No | No | - | [centers](centers.md) via (`center` -> `id`) |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `defer_acc_trans_center` | Center component of the composite reference to the related defer acc trans record. | `int4` | No | No | [account_trans](account_trans.md) via (`defer_acc_trans_center`, `defer_acc_trans_id`, `defer_acc_trans_subid` -> `center`, `id`, `subid`) | - |
| `defer_acc_trans_id` | Identifier component of the composite reference to the related defer acc trans record. | `int4` | No | No | [account_trans](account_trans.md) via (`defer_acc_trans_center`, `defer_acc_trans_id`, `defer_acc_trans_subid` -> `center`, `id`, `subid`) | - |
| `defer_acc_trans_subid` | Identifier of the related account trans record used by this row. | `int4` | No | No | [account_trans](account_trans.md) via (`defer_acc_trans_center`, `defer_acc_trans_id`, `defer_acc_trans_subid` -> `center`, `id`, `subid`) | - |
| `revenue_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `reversal_entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `reversal_acc_trans_center` | Center component of the composite reference to the related reversal acc trans record. | `int4` | Yes | No | [account_trans](account_trans.md) via (`reversal_acc_trans_center`, `reversal_acc_trans_id`, `reversal_acc_trans_subid` -> `center`, `id`, `subid`) | - |
| `reversal_acc_trans_id` | Identifier component of the composite reference to the related reversal acc trans record. | `int4` | Yes | No | [account_trans](account_trans.md) via (`reversal_acc_trans_center`, `reversal_acc_trans_id`, `reversal_acc_trans_subid` -> `center`, `id`, `subid`) | - |
| `reversal_acc_trans_subid` | Identifier of the related account trans record used by this row. | `int4` | Yes | No | [account_trans](account_trans.md) via (`reversal_acc_trans_center`, `reversal_acc_trans_id`, `reversal_acc_trans_subid` -> `center`, `id`, `subid`) | - |

# Relations
- FK-linked tables: outgoing FK to [account_trans](account_trans.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [cashregistertransactions](cashregistertransactions.md), [credit_note_line_vat_at_link](credit_note_line_vat_at_link.md), [credit_note_lines_mt](credit_note_lines_mt.md), [deliverylines_vat_at_link](deliverylines_vat_at_link.md), [gift_card_usages](gift_card_usages.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
