# invoice_lines_mt
Financial/transactional table for invoice lines mt records. It is typically used where rows are center-scoped; it appears in approximately 595 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`)<br>[invoices](invoices.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [invoices](invoices.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `productcenter` | Center component of the composite reference to the related product record. | `int4` | No | No | [products](products.md) via (`productcenter`, `productid` -> `center`, `id`) | - |
| `productid` | Identifier component of the composite reference to the related product record. | `int4` | No | No | [products](products.md) via (`productcenter`, `productid` -> `center`, `id`) | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `account_trans_center` | Center component of the composite reference to the related account trans record. | `int4` | Yes | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_id` | Identifier component of the composite reference to the related account trans record. | `int4` | Yes | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_subid` | Identifier of the related account trans record used by this row. | `int4` | Yes | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `quantity` | Operational field `quantity` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `text` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `product_cost` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `product_normal_price` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `total_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `sales_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | - |
| `remove_from_inventory` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `reason` | Operational field `reason` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `sponsor_invoice_subid` | Operational field `sponsor_invoice_subid` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `installment_plan_id` | Identifier of the related installment plans record used by this row. | `int4` | Yes | No | [installment_plans](installment_plans.md) via (`installment_plan_id` -> `id`) | - |
| `net_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `rebooking_acc_trans_center` | Center component of the composite reference to the related rebooking acc trans record. | `int4` | Yes | No | - | - |
| `rebooking_acc_trans_id` | Identifier component of the composite reference to the related rebooking acc trans record. | `int4` | Yes | No | - | - |
| `rebooking_acc_trans_subid` | Business attribute `rebooking_acc_trans_subid` used by invoice lines mt workflows and reporting. | `int4` | Yes | No | - | - |
| `rebooking_to_center` | Business attribute `rebooking_to_center` used by invoice lines mt workflows and reporting. | `int4` | Yes | No | - | - |
| `sales_commission` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `sales_units` | Operational field `sales_units` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `period_commission` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `flat_rate_commission` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `VARCHAR(100)` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (471 query files), [centers](centers.md) (457 query files), [products](products.md) (433 query files), [invoices](invoices.md) (412 query files), [ar_trans](ar_trans.md) (222 query files), [credit_note_lines_mt](credit_note_lines_mt.md) (195 query files).
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [centers](centers.md), [installment_plans](installment_plans.md), [invoices](invoices.md), [persons](persons.md), [products](products.md); incoming FK from [bundle_campaign_usages](bundle_campaign_usages.md), [clipcards](clipcards.md), [credit_note_lines_mt](credit_note_lines_mt.md), [gift_cards](gift_cards.md), [invoicelines_vat_at_link](invoicelines_vat_at_link.md), [participations](participations.md), [payment_requests](payment_requests.md), [spp_invoicelines_link](spp_invoicelines_link.md), [subscription_freeze_period](subscription_freeze_period.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [area_centers](area_centers.md), [attends](attends.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [booking_program_person_skills](booking_program_person_skills.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier.
