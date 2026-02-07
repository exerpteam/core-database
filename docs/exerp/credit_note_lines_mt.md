# credit_note_lines_mt
Operational table for credit note lines mt records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 230 query files; common companions include [invoice_lines_mt](invoice_lines_mt.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`)<br>[credit_notes](credit_notes.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [credit_notes](credit_notes.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `invoiceline_center` | Center component of the composite reference to the related invoiceline record. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_id` | Identifier component of the composite reference to the related invoiceline record. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_subid` | Identifier of the related invoice lines mt record used by this row. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `productcenter` | Center component of the composite reference to the related product record. | `int4` | No | No | [products](products.md) via (`productcenter`, `productid` -> `center`, `id`) | - |
| `productid` | Identifier component of the composite reference to the related product record. | `int4` | No | No | [products](products.md) via (`productcenter`, `productid` -> `center`, `id`) | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | Yes | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | Yes | No | - | - |
| `account_trans_center` | Center component of the composite reference to the related account trans record. | `int4` | Yes | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_id` | Identifier component of the composite reference to the related account trans record. | `int4` | Yes | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_subid` | Identifier of the related account trans record used by this row. | `int4` | Yes | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `quantity` | Operational field `quantity` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `text` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `credit_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | - |
| `canceltype` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `total_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `product_cost` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `reason` | Operational field `reason` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `installment_plan_id` | Identifier of the related installment plans record used by this row. | `int4` | Yes | No | [installment_plans](installment_plans.md) via (`installment_plan_id` -> `id`) | - |
| `cancel_reason` | Business attribute `cancel_reason` used by credit note lines mt workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `rebooking_acc_trans_center` | Center component of the composite reference to the related rebooking acc trans record. | `int4` | Yes | No | - | - |
| `rebooking_acc_trans_id` | Identifier component of the composite reference to the related rebooking acc trans record. | `int4` | Yes | No | - | - |
| `rebooking_acc_trans_subid` | Business attribute `rebooking_acc_trans_subid` used by credit note lines mt workflows and reporting. | `int4` | Yes | No | - | - |
| `rebooking_to_center` | Business attribute `rebooking_to_center` used by credit note lines mt workflows and reporting. | `int4` | Yes | No | - | - |
| `net_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `sales_commission` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `sales_units` | Operational field `sales_units` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `period_commission` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `flat_rate_commission` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |

# Relations
- Commonly used with: [invoice_lines_mt](invoice_lines_mt.md) (195 query files), [centers](centers.md) (186 query files), [persons](persons.md) (182 query files), [credit_notes](credit_notes.md) (156 query files), [invoices](invoices.md) (154 query files), [products](products.md) (149 query files).
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [centers](centers.md), [credit_notes](credit_notes.md), [installment_plans](installment_plans.md), [invoice_lines_mt](invoice_lines_mt.md), [products](products.md); incoming FK from [card_clip_usages](card_clip_usages.md), [credit_note_line_vat_at_link](credit_note_line_vat_at_link.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [area_centers](area_centers.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [bookings](bookings.md), [bundle_campaign_usages](bundle_campaign_usages.md), [cashregisters](cashregisters.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
