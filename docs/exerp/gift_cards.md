# gift_cards
Operational table for gift cards records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 31 query files; common companions include [centers](centers.md), [entityidentifiers](entityidentifiers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `STATE` | State code representing the current processing state. | `int4` | No | No | - | - |
| `amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - |
| `product_center` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`product_center`, `product_id` -> `center`, `id`) | - |
| `product_id` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`product_center`, `product_id` -> `center`, `id`) | - |
| `invoiceline_center` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_id` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_subid` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `expirationdate` | Calendar date used for lifecycle and reporting filters. | `DATE` | No | No | - | - |
| `use_time` | Epoch timestamp for use. | `int8` | Yes | No | - | - |
| `purchase_time` | Epoch timestamp for purchase. | `int8` | Yes | No | - | - |
| `payer_center` | Center part of the reference to related payer data. | `int4` | Yes | No | - | - |
| `payer_id` | Identifier of the related payer record. | `int4` | Yes | No | - | - |
| `amount_remaining` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (22 query files), [entityidentifiers](entityidentifiers.md) (20 query files), [persons](persons.md) (17 query files), [products](products.md) (12 query files), [gift_card_usages](gift_card_usages.md) (12 query files), [account_trans](account_trans.md) (11 query files).
- FK-linked tables: outgoing FK to [invoice_lines_mt](invoice_lines_mt.md), [products](products.md); incoming FK from [gift_card_usages](gift_card_usages.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [accounts](accounts.md), [bundle_campaign_usages](bundle_campaign_usages.md), [centers](centers.md), [clipcards](clipcards.md), [clipcardtypes](clipcardtypes.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery_lines_mt](delivery_lines_mt.md), [employees](employees.md), [installment_plans](installment_plans.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
