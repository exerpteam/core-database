# lease_products
Operational table for lease products records in the Exerp schema. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [products](products.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [products](products.md) via (`center`, `id` -> `center`, `id`) | - |
| `max_minutes` | Business attribute `max_minutes` used by lease products workflows and reporting. | `int4` | No | No | - | - |
| `instructor_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [products](products.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [centers](centers.md), [clipcardtypes](clipcardtypes.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery_lines_mt](delivery_lines_mt.md), [gift_cards](gift_cards.md), [inventory_trans](inventory_trans.md), [invoice_lines_mt](invoice_lines_mt.md), [product_account_configurations](product_account_configurations.md), [product_and_product_group_link](product_and_product_group_link.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
