# deliverylines_vat_at_link
Bridge table that links related entities for deliverylines vat at link relationships.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `deliveryline_center` | Center component of the composite reference to the related deliveryline record. | `int4` | No | No | [delivery_lines_mt](delivery_lines_mt.md) via (`deliveryline_center`, `deliveryline_id`, `deliveryline_subid` -> `center`, `id`, `subid`) | - |
| `deliveryline_id` | Identifier component of the composite reference to the related deliveryline record. | `int4` | No | No | [delivery_lines_mt](delivery_lines_mt.md) via (`deliveryline_center`, `deliveryline_id`, `deliveryline_subid` -> `center`, `id`, `subid`) | - |
| `deliveryline_subid` | Identifier of the related delivery lines mt record used by this row. | `int4` | No | No | [delivery_lines_mt](delivery_lines_mt.md) via (`deliveryline_center`, `deliveryline_id`, `deliveryline_subid` -> `center`, `id`, `subid`) | - |
| `vat_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `account_trans_center` | Center component of the composite reference to the related account trans record. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_id` | Identifier component of the composite reference to the related account trans record. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_subid` | Identifier of the related account trans record used by this row. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |

# Relations
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [delivery_lines_mt](delivery_lines_mt.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [cashregistertransactions](cashregistertransactions.md), [centers](centers.md), [credit_note_line_vat_at_link](credit_note_line_vat_at_link.md), [credit_note_lines_mt](credit_note_lines_mt.md), [deferrals](deferrals.md).
