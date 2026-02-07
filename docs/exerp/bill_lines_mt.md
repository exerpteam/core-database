# bill_lines_mt
Operational table for bill lines mt records in the Exerp schema. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [bills](bills.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [bills](bills.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `account_trans_center` | Center component of the composite reference to the related account trans record. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_id` | Identifier component of the composite reference to the related account trans record. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_subid` | Identifier of the related account trans record used by this row. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `text` | Free-text content providing business context or operator notes for the record. | `bytea` | Yes | No | - | - |
| `text2` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [bills](bills.md); incoming FK from [billlines_vat_at_link](billlines_vat_at_link.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [cashregistertransactions](cashregistertransactions.md), [credit_note_line_vat_at_link](credit_note_line_vat_at_link.md), [credit_note_lines_mt](credit_note_lines_mt.md), [deferrals](deferrals.md), [deliverylines_vat_at_link](deliverylines_vat_at_link.md), [employees](employees.md), [gift_card_usages](gift_card_usages.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
