# bundle_campaign_usages
Operational table for bundle campaign usages records in the Exerp schema. It is typically used where it appears in approximately 4 query files; common companions include [bundle_campaign](bundle_campaign.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `serial` | No | Yes | - | - |
| `invoice_line_center` | Center component of the composite reference to the related invoice line record. | `int4` | No | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoice_line_center`, `invoice_line_id`, `invoice_line_sub_id` -> `center`, `id`, `subid`) | - |
| `invoice_line_id` | Identifier component of the composite reference to the related invoice line record. | `int4` | No | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoice_line_center`, `invoice_line_id`, `invoice_line_sub_id` -> `center`, `id`, `subid`) | - |
| `invoice_line_sub_id` | Identifier of the related invoice lines mt record used by this row. | `int4` | No | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoice_line_center`, `invoice_line_id`, `invoice_line_sub_id` -> `center`, `id`, `subid`) | - |
| `campaign_id` | Identifier of the related bundle campaign record used by this row. | `int4` | No | No | [bundle_campaign](bundle_campaign.md) via (`campaign_id` -> `id`) | - |

# Relations
- Commonly used with: [bundle_campaign](bundle_campaign.md) (3 query files), [centers](centers.md) (3 query files), [invoice_lines_mt](invoice_lines_mt.md) (3 query files), [invoices](invoices.md) (3 query files), [persons](persons.md) (3 query files).
- FK-linked tables: outgoing FK to [bundle_campaign](bundle_campaign.md), [invoice_lines_mt](invoice_lines_mt.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [bundle_campaign_product](bundle_campaign_product.md), [centers](centers.md), [clipcards](clipcards.md), [credit_note_lines_mt](credit_note_lines_mt.md), [gift_cards](gift_cards.md), [installment_plans](installment_plans.md), [invoicelines_vat_at_link](invoicelines_vat_at_link.md), [invoices](invoices.md), [participations](participations.md).
