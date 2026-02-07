# invoicelines_vat_at_link
Bridge table that links related entities for invoicelines vat at link relationships. It is typically used where it appears in approximately 90 query files; common companions include [invoice_lines_mt](invoice_lines_mt.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `invoiceline_center` | Center component of the composite reference to the related invoiceline record. | `int4` | No | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_id` | Identifier component of the composite reference to the related invoiceline record. | `int4` | No | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_subid` | Identifier of the related invoice lines mt record used by this row. | `int4` | No | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_center` | Center component of the composite reference to the related account trans record. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_id` | Identifier component of the composite reference to the related account trans record. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_subid` | Identifier of the related account trans record used by this row. | `int4` | No | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `rate` | Operational field `rate` used in query filtering and reporting transformations. | `NUMERIC(0,0)` | No | No | - | - |
| `orig_rate` | Business attribute `orig_rate` used by invoicelines vat at link workflows and reporting. | `NUMERIC(0,0)` | No | No | - | - |

# Relations
- Commonly used with: [invoice_lines_mt](invoice_lines_mt.md) (90 query files), [centers](centers.md) (81 query files), [products](products.md) (77 query files), [invoices](invoices.md) (72 query files), [persons](persons.md) (72 query files), [ar_trans](ar_trans.md) (50 query files).
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [invoice_lines_mt](invoice_lines_mt.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [bundle_campaign_usages](bundle_campaign_usages.md), [cashregistertransactions](cashregistertransactions.md), [centers](centers.md), [clipcards](clipcards.md), [credit_note_line_vat_at_link](credit_note_line_vat_at_link.md).
