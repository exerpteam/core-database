# spp_invoicelines_link
Bridge table that links related entities for spp invoicelines link relationships. It is typically used where it appears in approximately 233 query files; common companions include [persons](persons.md), [subscriptionperiodparts](subscriptionperiodparts.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `invoiceline_center` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `period_center` | Center component of the composite reference to the related period record. | `int4` | No | No | [subscriptionperiodparts](subscriptionperiodparts.md) via (`period_center`, `period_id`, `period_subid` -> `center`, `id`, `subid`) | - |
| `period_id` | Identifier component of the composite reference to the related period record. | `int4` | No | No | [subscriptionperiodparts](subscriptionperiodparts.md) via (`period_center`, `period_id`, `period_subid` -> `center`, `id`, `subid`) | - |
| `period_subid` | Identifier of the related subscriptionperiodparts record used by this row. | `int4` | No | No | [subscriptionperiodparts](subscriptionperiodparts.md) via (`period_center`, `period_id`, `period_subid` -> `center`, `id`, `subid`) | - |

# Relations
- Commonly used with: [persons](persons.md) (193 query files), [subscriptionperiodparts](subscriptionperiodparts.md) (189 query files), [subscriptions](subscriptions.md) (189 query files), [products](products.md) (181 query files), [centers](centers.md) (166 query files), [invoices](invoices.md) (133 query files).
- FK-linked tables: outgoing FK to [invoice_lines_mt](invoice_lines_mt.md), [subscriptionperiodparts](subscriptionperiodparts.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [bundle_campaign_usages](bundle_campaign_usages.md), [centers](centers.md), [clipcards](clipcards.md), [credit_note_lines_mt](credit_note_lines_mt.md), [gift_cards](gift_cards.md), [installment_plans](installment_plans.md), [invoicelines_vat_at_link](invoicelines_vat_at_link.md), [invoices](invoices.md), [participations](participations.md).
