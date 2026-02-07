# billlines_vat_at_link
Bridge table that links related entities for billlines vat at link relationships.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `billline_center` | Foreign key field linking this record to `bill_lines_mt`. | `int4` | No | No | [bill_lines_mt](bill_lines_mt.md) via (`billline_center`, `billline_id`, `billline_subid` -> `center`, `id`, `subid`) | - | `101` |
| `billline_id` | Foreign key field linking this record to `bill_lines_mt`. | `int4` | No | No | [bill_lines_mt](bill_lines_mt.md) via (`billline_center`, `billline_id`, `billline_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `billline_subid` | Foreign key field linking this record to `bill_lines_mt`. | `int4` | No | No | [bill_lines_mt](bill_lines_mt.md) via (`billline_center`, `billline_id`, `billline_subid` -> `center`, `id`, `subid`) | - | `1` |
| `account_trans_center` | Foreign key field linking this record to `account_trans`. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - | `101` |
| `account_trans_id` | Foreign key field linking this record to `account_trans`. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `account_trans_subid` | Foreign key field linking this record to `account_trans`. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - | `1` |

# Relations
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [bill_lines_mt](bill_lines_mt.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [bills](bills.md), [cashregistertransactions](cashregistertransactions.md), [credit_note_line_vat_at_link](credit_note_line_vat_at_link.md), [credit_note_lines_mt](credit_note_lines_mt.md), [deferrals](deferrals.md), [deliverylines_vat_at_link](deliverylines_vat_at_link.md), [gift_card_usages](gift_card_usages.md).
