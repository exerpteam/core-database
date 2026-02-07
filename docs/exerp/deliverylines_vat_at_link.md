# deliverylines_vat_at_link
Bridge table that links related entities for deliverylines vat at link relationships.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `deliveryline_center` | Foreign key field linking this record to `delivery_lines_mt`. | `int4` | No | No | [delivery_lines_mt](delivery_lines_mt.md) via (`deliveryline_center`, `deliveryline_id`, `deliveryline_subid` -> `center`, `id`, `subid`) | - |
| `deliveryline_id` | Foreign key field linking this record to `delivery_lines_mt`. | `int4` | No | No | [delivery_lines_mt](delivery_lines_mt.md) via (`deliveryline_center`, `deliveryline_id`, `deliveryline_subid` -> `center`, `id`, `subid`) | - |
| `deliveryline_subid` | Foreign key field linking this record to `delivery_lines_mt`. | `int4` | No | No | [delivery_lines_mt](delivery_lines_mt.md) via (`deliveryline_center`, `deliveryline_id`, `deliveryline_subid` -> `center`, `id`, `subid`) | - |
| `vat_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `account_trans_center` | Foreign key field linking this record to `account_trans`. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_id` | Foreign key field linking this record to `account_trans`. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_subid` | Foreign key field linking this record to `account_trans`. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |

# Relations
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [delivery_lines_mt](delivery_lines_mt.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [cashregistertransactions](cashregistertransactions.md), [centers](centers.md), [credit_note_line_vat_at_link](credit_note_line_vat_at_link.md), [credit_note_lines_mt](credit_note_lines_mt.md), [deferrals](deferrals.md).
