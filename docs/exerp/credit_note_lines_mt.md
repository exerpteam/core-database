# credit_note_lines_mt
Operational table for credit note lines mt records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 230 query files; common companions include [invoice_lines_mt](invoice_lines_mt.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`)<br>[credit_notes](credit_notes.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [credit_notes](credit_notes.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - |
| `invoiceline_center` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_id` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_subid` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `productcenter` | Foreign key field linking this record to `products`. | `int4` | No | No | [products](products.md) via (`productcenter`, `productid` -> `center`, `id`) | - |
| `productid` | Foreign key field linking this record to `products`. | `int4` | No | No | [products](products.md) via (`productcenter`, `productid` -> `center`, `id`) | - |
| `person_center` | Center part of the reference to related person data. | `int4` | Yes | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) |
| `person_id` | Identifier of the related person record. | `int4` | Yes | No | - | - |
| `account_trans_center` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_id` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_subid` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `quantity` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `credit_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `canceltype` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `total_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `product_cost` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `reason` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `installment_plan_id` | Foreign key field linking this record to `installment_plans`. | `int4` | Yes | No | [installment_plans](installment_plans.md) via (`installment_plan_id` -> `id`) | - |
| `cancel_reason` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `rebooking_acc_trans_center` | Center part of the reference to related rebooking acc trans data. | `int4` | Yes | No | - | - |
| `rebooking_acc_trans_id` | Identifier of the related rebooking acc trans record. | `int4` | Yes | No | - | - |
| `rebooking_acc_trans_subid` | Sub-identifier for related rebooking acc trans detail rows. | `int4` | Yes | No | - | - |
| `rebooking_to_center` | Center part of the reference to related rebooking to data. | `int4` | Yes | No | - | - |
| `net_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `sales_commission` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `sales_units` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `period_commission` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `flat_rate_commission` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |

# Relations
- Commonly used with: [invoice_lines_mt](invoice_lines_mt.md) (195 query files), [centers](centers.md) (186 query files), [persons](persons.md) (182 query files), [credit_notes](credit_notes.md) (156 query files), [invoices](invoices.md) (154 query files), [products](products.md) (149 query files).
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [centers](centers.md), [credit_notes](credit_notes.md), [installment_plans](installment_plans.md), [invoice_lines_mt](invoice_lines_mt.md), [products](products.md); incoming FK from [card_clip_usages](card_clip_usages.md), [credit_note_line_vat_at_link](credit_note_line_vat_at_link.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [area_centers](area_centers.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [bookings](bookings.md), [bundle_campaign_usages](bundle_campaign_usages.md), [cashregisters](cashregisters.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
