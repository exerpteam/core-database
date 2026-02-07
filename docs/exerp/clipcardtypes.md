# clipcardtypes
Operational table for clipcardtypes records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 59 query files; common companions include [products](products.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [products](products.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [products](products.md) via (`center`, `id` -> `center`, `id`) | - |
| `add_on_to_center` | Center component of the composite reference to the related add on to record. | `int4` | Yes | No | - | - |
| `add_on_to_id` | Identifier component of the composite reference to the related add on to record. | `int4` | Yes | No | - | - |
| `clip_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | No | No | - | - |
| `period_unit` | Business attribute `period_unit` used by clipcardtypes workflows and reporting. | `int4` | Yes | No | - | - |
| `period_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `period_round` | Business attribute `period_round` used by clipcardtypes workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `age_restriction_type` | Classification code describing the age restriction type category (for example: BETWEEN, LESS THAN, LESS THEN, MORE THAN). | `int4` | No | No | - | - |
| `age_restriction_value` | Business attribute `age_restriction_value` used by clipcardtypes workflows and reporting. | `int4` | No | No | - | - |
| `sex_restriction` | Business attribute `sex_restriction` used by clipcardtypes workflows and reporting. | `int4` | No | No | - | - |
| `info_text` | Business attribute `info_text` used by clipcardtypes workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `buyoutfeeproduct_center` | Center component of the composite reference to the related buyoutfeeproduct record. | `int4` | Yes | No | - | - |
| `buyoutfeeproduct_id` | Identifier component of the composite reference to the related buyoutfeeproduct record. | `int4` | Yes | No | - | - |
| `contract_template_id` | Identifier for the related contract template entity used by this record. | `int4` | Yes | No | - | - |
| `clipcard_usage_commission` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `assigned_staff_group` | Reference component identifying the staff member assigned to handle the record. | `int4` | Yes | No | - | - |
| `buyout_fee_percentage` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `clips_pack_size` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `age_restriction_min_value` | Business attribute `age_restriction_min_value` used by clipcardtypes workflows and reporting. | `int4` | Yes | No | - | - |
| `age_restriction_max_value` | Business attribute `age_restriction_max_value` used by clipcardtypes workflows and reporting. | `int4` | Yes | No | - | - |
| `ct_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | - |

# Relations
- Commonly used with: [products](products.md) (59 query files), [persons](persons.md) (57 query files), [clipcards](clipcards.md) (54 query files), [centers](centers.md) (52 query files), [invoices](invoices.md) (28 query files), [product_group](product_group.md) (24 query files).
- FK-linked tables: outgoing FK to [products](products.md); incoming FK from [clipcards](clipcards.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [card_clip_usages](card_clip_usages.md), [centers](centers.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery_lines_mt](delivery_lines_mt.md), [gift_cards](gift_cards.md), [inventory_trans](inventory_trans.md), [invoice_lines_mt](invoice_lines_mt.md), [lease_products](lease_products.md), [persons](persons.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
