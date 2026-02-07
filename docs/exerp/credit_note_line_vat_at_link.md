# credit_note_line_vat_at_link
Bridge table that links related entities for credit note line vat at link relationships. It is typically used where it appears in approximately 35 query files; common companions include [centers](centers.md), [credit_note_lines_mt](credit_note_lines_mt.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `credit_note_line_center` | Foreign key field linking this record to `credit_note_lines_mt`. | `int4` | No | No | [credit_note_lines_mt](credit_note_lines_mt.md) via (`credit_note_line_center`, `credit_note_line_id`, `credit_note_line_subid` -> `center`, `id`, `subid`) | - | `101` |
| `credit_note_line_id` | Foreign key field linking this record to `credit_note_lines_mt`. | `int4` | No | No | [credit_note_lines_mt](credit_note_lines_mt.md) via (`credit_note_line_center`, `credit_note_line_id`, `credit_note_line_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `credit_note_line_subid` | Foreign key field linking this record to `credit_note_lines_mt`. | `int4` | No | No | [credit_note_lines_mt](credit_note_lines_mt.md) via (`credit_note_line_center`, `credit_note_line_id`, `credit_note_line_subid` -> `center`, `id`, `subid`) | - | `1` |
| `account_trans_center` | Foreign key field linking this record to `account_trans`. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - | `101` |
| `account_trans_id` | Foreign key field linking this record to `account_trans`. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `account_trans_subid` | Foreign key field linking this record to `account_trans`. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - | `1` |
| `rate` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `orig_rate` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |

# Relations
- Commonly used with: [centers](centers.md) (35 query files), [credit_note_lines_mt](credit_note_lines_mt.md) (35 query files), [invoice_lines_mt](invoice_lines_mt.md) (34 query files), [persons](persons.md) (33 query files), [invoices](invoices.md) (31 query files), [credit_notes](credit_notes.md) (30 query files).
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [credit_note_lines_mt](credit_note_lines_mt.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [card_clip_usages](card_clip_usages.md), [cashregistertransactions](cashregistertransactions.md), [centers](centers.md), [credit_notes](credit_notes.md), [deferrals](deferrals.md).
