# invoice_lines_mt
Financial/transactional table for invoice lines mt records. It is typically used where rows are center-scoped; it appears in approximately 595 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`)<br>[invoices](invoices.md) via (`center`, `id` -> `center`, `id`) | - | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [invoices](invoices.md) via (`center`, `id` -> `center`, `id`) | - | `1001` |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - | `1` |
| `productcenter` | Foreign key field linking this record to `products`. | `int4` | No | No | [products](products.md) via (`productcenter`, `productid` -> `center`, `id`) | - | `42` |
| `productid` | Foreign key field linking this record to `products`. | `int4` | No | No | [products](products.md) via (`productcenter`, `productid` -> `center`, `id`) | - | `42` |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `101` |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `1001` |
| `account_trans_center` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - | `101` |
| `account_trans_id` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `account_trans_subid` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - | `1` |
| `quantity` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `product_cost` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `product_normal_price` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `total_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `sales_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `remove_from_inventory` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `reason` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `sponsor_invoice_subid` | Sub-identifier for related sponsor invoice detail rows. | `int4` | Yes | No | - | - | `1` |
| `installment_plan_id` | Foreign key field linking this record to `installment_plans`. | `int4` | Yes | No | [installment_plans](installment_plans.md) via (`installment_plan_id` -> `id`) | - | `1001` |
| `net_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `rebooking_acc_trans_center` | Center part of the reference to related rebooking acc trans data. | `int4` | Yes | No | - | - | `101` |
| `rebooking_acc_trans_id` | Identifier of the related rebooking acc trans record. | `int4` | Yes | No | - | - | `1001` |
| `rebooking_acc_trans_subid` | Sub-identifier for related rebooking acc trans detail rows. | `int4` | Yes | No | - | - | `1` |
| `rebooking_to_center` | Center part of the reference to related rebooking to data. | `int4` | Yes | No | - | - | `101` |
| `sales_commission` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `sales_units` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `period_commission` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `flat_rate_commission` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `external_id` | External/business identifier used in integrations and exports. | `VARCHAR(100)` | Yes | No | - | - | `EXT-1001` |

# Relations
- Commonly used with: [persons](persons.md) (471 query files), [centers](centers.md) (457 query files), [products](products.md) (433 query files), [invoices](invoices.md) (412 query files), [ar_trans](ar_trans.md) (222 query files), [credit_note_lines_mt](credit_note_lines_mt.md) (195 query files).
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [centers](centers.md), [installment_plans](installment_plans.md), [invoices](invoices.md), [persons](persons.md), [products](products.md); incoming FK from [bundle_campaign_usages](bundle_campaign_usages.md), [clipcards](clipcards.md), [credit_note_lines_mt](credit_note_lines_mt.md), [gift_cards](gift_cards.md), [invoicelines_vat_at_link](invoicelines_vat_at_link.md), [participations](participations.md), [payment_requests](payment_requests.md), [spp_invoicelines_link](spp_invoicelines_link.md), [subscription_freeze_period](subscription_freeze_period.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [area_centers](area_centers.md), [attends](attends.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [booking_program_person_skills](booking_program_person_skills.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier.
