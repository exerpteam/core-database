# shopping_basket_invoice_link
Bridge table that links related entities for shopping basket invoice link relationships. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `shopping_basket_id` | Foreign key field linking this record to `shopping_baskets`. | `int4` | No | Yes | [shopping_baskets](shopping_baskets.md) via (`shopping_basket_id` -> `id`) | - |
| `invoice_center` | Foreign key field linking this record to `invoices`. | `int4` | No | Yes | [invoices](invoices.md) via (`invoice_center`, `invoice_id` -> `center`, `id`) | - |
| `invoice_id` | Foreign key field linking this record to `invoices`. | `int4` | No | Yes | [invoices](invoices.md) via (`invoice_center`, `invoice_id` -> `center`, `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [invoices](invoices.md), [shopping_baskets](shopping_baskets.md).
- Second-level FK neighborhood includes: [cashregisters](cashregisters.md), [credit_notes](credit_notes.md), [creditcardtransactions](creditcardtransactions.md), [employees](employees.md), [invoice_lines_mt](invoice_lines_mt.md), [persons](persons.md).
