# gift_cards
Operational table for gift cards records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 31 query files; common companions include [centers](centers.md), [entityidentifiers](entityidentifiers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `int4` | No | No | - | - |
| `amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `product_center` | Center component of the composite reference to the related product record. | `int4` | Yes | No | [products](products.md) via (`product_center`, `product_id` -> `center`, `id`) | - |
| `product_id` | Identifier component of the composite reference to the related product record. | `int4` | Yes | No | [products](products.md) via (`product_center`, `product_id` -> `center`, `id`) | - |
| `invoiceline_center` | Center component of the composite reference to the related invoiceline record. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_id` | Identifier component of the composite reference to the related invoiceline record. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_subid` | Identifier of the related invoice lines mt record used by this row. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `expirationdate` | Business attribute `expirationdate` used by gift cards workflows and reporting. | `DATE` | No | No | - | - |
| `use_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `purchase_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `payer_center` | Center component of the composite reference to the related payer record. | `int4` | Yes | No | - | - |
| `payer_id` | Identifier component of the composite reference to the related payer record. | `int4` | Yes | No | - | - |
| `amount_remaining` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (22 query files), [entityidentifiers](entityidentifiers.md) (20 query files), [persons](persons.md) (17 query files), [products](products.md) (12 query files), [gift_card_usages](gift_card_usages.md) (12 query files), [account_trans](account_trans.md) (11 query files).
- FK-linked tables: outgoing FK to [invoice_lines_mt](invoice_lines_mt.md), [products](products.md); incoming FK from [gift_card_usages](gift_card_usages.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [accounts](accounts.md), [bundle_campaign_usages](bundle_campaign_usages.md), [centers](centers.md), [clipcards](clipcards.md), [clipcardtypes](clipcardtypes.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery_lines_mt](delivery_lines_mt.md), [employees](employees.md), [installment_plans](installment_plans.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
