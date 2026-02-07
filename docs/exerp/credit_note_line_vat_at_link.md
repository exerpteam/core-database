# credit_note_line_vat_at_link
Bridge table that links related entities for credit note line vat at link relationships. It is typically used where it appears in approximately 35 query files; common companions include [centers](centers.md), [credit_note_lines_mt](credit_note_lines_mt.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `credit_note_line_center` | Center component of the composite reference to the related credit note line record. | `int4` | No | No | [credit_note_lines_mt](credit_note_lines_mt.md) via (`credit_note_line_center`, `credit_note_line_id`, `credit_note_line_subid` -> `center`, `id`, `subid`) | - |
| `credit_note_line_id` | Identifier component of the composite reference to the related credit note line record. | `int4` | No | No | [credit_note_lines_mt](credit_note_lines_mt.md) via (`credit_note_line_center`, `credit_note_line_id`, `credit_note_line_subid` -> `center`, `id`, `subid`) | - |
| `credit_note_line_subid` | Identifier of the related credit note lines mt record used by this row. | `int4` | No | No | [credit_note_lines_mt](credit_note_lines_mt.md) via (`credit_note_line_center`, `credit_note_line_id`, `credit_note_line_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_center` | Center component of the composite reference to the related account trans record. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_id` | Identifier component of the composite reference to the related account trans record. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_subid` | Identifier of the related account trans record used by this row. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `rate` | Operational field `rate` used in query filtering and reporting transformations. | `NUMERIC(0,0)` | No | No | - | - |
| `orig_rate` | Business attribute `orig_rate` used by credit note line vat at link workflows and reporting. | `NUMERIC(0,0)` | No | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (35 query files), [credit_note_lines_mt](credit_note_lines_mt.md) (35 query files), [invoice_lines_mt](invoice_lines_mt.md) (34 query files), [persons](persons.md) (33 query files), [invoices](invoices.md) (31 query files), [credit_notes](credit_notes.md) (30 query files).
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [credit_note_lines_mt](credit_note_lines_mt.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [card_clip_usages](card_clip_usages.md), [cashregistertransactions](cashregistertransactions.md), [centers](centers.md), [credit_notes](credit_notes.md), [deferrals](deferrals.md).
