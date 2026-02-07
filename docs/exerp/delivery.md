# delivery
Operational table for delivery records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 24 query files; common companions include [centers](centers.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`) | - | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `supplier_center` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`supplier_center`, `supplier_id` -> `center`, `id`)<br>[supplier](supplier.md) via (`supplier_center`, `supplier_id` -> `center`, `id`) | - | `101` |
| `supplier_id` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`supplier_center`, `supplier_id` -> `center`, `id`)<br>[supplier](supplier.md) via (`supplier_center`, `supplier_id` -> `center`, `id`) | - | `1001` |
| `invoice_no` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `order_no` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `delivery_date` | Date for delivery. | `DATE` | No | No | - | - | `2025-01-31` |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - | `1738281600000` |
| `shipping_cost` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `101` |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `1001` |
| `coment` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `inventory` | Foreign key field linking this record to `inventory`. | `int4` | No | No | [inventory](inventory.md) via (`inventory` -> `id`) | - | `42` |
| `payment_trans_center` | Center part of the reference to related payment trans data. | `int4` | Yes | No | - | - | `101` |
| `payment_trans_id` | Identifier of the related payment trans record. | `int4` | Yes | No | - | - | `1001` |
| `payment_trans_subid` | Sub-identifier for related payment trans detail rows. | `int4` | Yes | No | - | - | `1` |
| `paid_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `paid_date` | Date for paid. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `delivery_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |

# Relations
- Commonly used with: [centers](centers.md) (22 query files), [persons](persons.md) (13 query files), [products](products.md) (10 query files), [inventory](inventory.md) (10 query files), [messages](messages.md) (9 query files), [invoice_lines_mt](invoice_lines_mt.md) (9 query files).
- FK-linked tables: outgoing FK to [centers](centers.md), [employees](employees.md), [inventory](inventory.md), [persons](persons.md), [supplier](supplier.md); incoming FK from [delivery_lines_mt](delivery_lines_mt.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [accountingperiods](accountingperiods.md), [advance_notices](advance_notices.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [area_centers](area_centers.md), [attends](attends.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
