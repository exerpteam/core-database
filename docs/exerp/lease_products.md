# lease_products
Operational table for lease products records in the Exerp schema. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [products](products.md) via (`center`, `id` -> `center`, `id`) | - | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [products](products.md) via (`center`, `id` -> `center`, `id`) | - | `1001` |
| `max_minutes` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `instructor_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |

# Relations
- FK-linked tables: outgoing FK to [products](products.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [centers](centers.md), [clipcardtypes](clipcardtypes.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery_lines_mt](delivery_lines_mt.md), [gift_cards](gift_cards.md), [inventory_trans](inventory_trans.md), [invoice_lines_mt](invoice_lines_mt.md), [product_account_configurations](product_account_configurations.md), [product_and_product_group_link](product_and_product_group_link.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
