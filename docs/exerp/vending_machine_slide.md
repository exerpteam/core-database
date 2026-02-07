# vending_machine_slide
Operational table for vending machine slide records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `vending_machine` | Identifier of the related vending machine record used by this row. | `int4` | No | No | [vending_machine](vending_machine.md) via (`vending_machine` -> `id`) | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `product_center` | Center component of the composite reference to the related product record. | `int4` | No | No | [products](products.md) via (`product_center`, `product_id` -> `center`, `id`) | - |
| `product_id` | Identifier component of the composite reference to the related product record. | `int4` | No | No | [products](products.md) via (`product_center`, `product_id` -> `center`, `id`) | - |
| `product_capacity` | Operational counter/limit used for processing control and performance monitoring. | `int4` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [products](products.md), [vending_machine](vending_machine.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [cashregisters](cashregisters.md), [centers](centers.md), [clipcardtypes](clipcardtypes.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery_lines_mt](delivery_lines_mt.md), [gift_cards](gift_cards.md), [inventory_trans](inventory_trans.md), [invoice_lines_mt](invoice_lines_mt.md), [lease_products](lease_products.md).
