# clipcardtypes
Operational table for clipcardtypes records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 59 query files; common companions include [products](products.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [products](products.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [products](products.md) via (`center`, `id` -> `center`, `id`) | - |
| `add_on_to_center` | Center part of the reference to related add on to data. | `int4` | Yes | No | - | - |
| `add_on_to_id` | Identifier of the related add on to record. | `int4` | Yes | No | - | - |
| `clip_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `period_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `period_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `period_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `age_restriction_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `age_restriction_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `sex_restriction` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `info_text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `buyoutfeeproduct_center` | Center part of the reference to related buyoutfeeproduct data. | `int4` | Yes | No | - | - |
| `buyoutfeeproduct_id` | Identifier of the related buyoutfeeproduct record. | `int4` | Yes | No | - | - |
| `contract_template_id` | Identifier of the related contract template record. | `int4` | Yes | No | - | - |
| `clipcard_usage_commission` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `assigned_staff_group` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `buyout_fee_percentage` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `clips_pack_size` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `age_restriction_min_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `age_restriction_max_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `ct_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |

# Relations
- Commonly used with: [products](products.md) (59 query files), [persons](persons.md) (57 query files), [clipcards](clipcards.md) (54 query files), [centers](centers.md) (52 query files), [invoices](invoices.md) (28 query files), [product_group](product_group.md) (24 query files).
- FK-linked tables: outgoing FK to [products](products.md); incoming FK from [clipcards](clipcards.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [card_clip_usages](card_clip_usages.md), [centers](centers.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery_lines_mt](delivery_lines_mt.md), [gift_cards](gift_cards.md), [inventory_trans](inventory_trans.md), [invoice_lines_mt](invoice_lines_mt.md), [lease_products](lease_products.md), [persons](persons.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
