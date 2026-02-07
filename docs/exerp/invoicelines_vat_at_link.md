# invoicelines_vat_at_link
Bridge table that links related entities for invoicelines vat at link relationships. It is typically used where it appears in approximately 90 query files; common companions include [invoice_lines_mt](invoice_lines_mt.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `invoiceline_center` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | No | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - | `101` |
| `invoiceline_id` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | No | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `invoiceline_subid` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | No | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - | `1` |
| `account_trans_center` | Foreign key field linking this record to `account_trans`. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - | `101` |
| `account_trans_id` | Foreign key field linking this record to `account_trans`. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `account_trans_subid` | Foreign key field linking this record to `account_trans`. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - | `1` |
| `rate` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `orig_rate` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |

# Relations
- Commonly used with: [invoice_lines_mt](invoice_lines_mt.md) (90 query files), [centers](centers.md) (81 query files), [products](products.md) (77 query files), [invoices](invoices.md) (72 query files), [persons](persons.md) (72 query files), [ar_trans](ar_trans.md) (50 query files).
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [invoice_lines_mt](invoice_lines_mt.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [bundle_campaign_usages](bundle_campaign_usages.md), [cashregistertransactions](cashregistertransactions.md), [centers](centers.md), [clipcards](clipcards.md), [credit_note_line_vat_at_link](credit_note_line_vat_at_link.md).
