# billlines_vat_at_link
Bridge table that links related entities for billlines vat at link relationships.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `billline_center` | Center component of the composite reference to the related billline record. | `int4` | No | No | [bill_lines_mt](bill_lines_mt.md) via (`billline_center`, `billline_id`, `billline_subid` -> `center`, `id`, `subid`) | - |
| `billline_id` | Identifier component of the composite reference to the related billline record. | `int4` | No | No | [bill_lines_mt](bill_lines_mt.md) via (`billline_center`, `billline_id`, `billline_subid` -> `center`, `id`, `subid`) | - |
| `billline_subid` | Identifier of the related bill lines mt record used by this row. | `int4` | No | No | [bill_lines_mt](bill_lines_mt.md) via (`billline_center`, `billline_id`, `billline_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_center` | Center component of the composite reference to the related account trans record. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_id` | Identifier component of the composite reference to the related account trans record. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_subid` | Identifier of the related account trans record used by this row. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |

# Relations
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [bill_lines_mt](bill_lines_mt.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [bills](bills.md), [cashregistertransactions](cashregistertransactions.md), [credit_note_line_vat_at_link](credit_note_line_vat_at_link.md), [credit_note_lines_mt](credit_note_lines_mt.md), [deferrals](deferrals.md), [deliverylines_vat_at_link](deliverylines_vat_at_link.md), [gift_card_usages](gift_card_usages.md).
