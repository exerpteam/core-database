# delivery
Operational table for delivery records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 24 query files; common companions include [centers](centers.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `supplier_center` | Center component of the composite reference to the related supplier record. | `int4` | No | No | [persons](persons.md) via (`supplier_center`, `supplier_id` -> `center`, `id`)<br>[supplier](supplier.md) via (`supplier_center`, `supplier_id` -> `center`, `id`) | - |
| `supplier_id` | Identifier component of the composite reference to the related supplier record. | `int4` | No | No | [persons](persons.md) via (`supplier_center`, `supplier_id` -> `center`, `id`)<br>[supplier](supplier.md) via (`supplier_center`, `supplier_id` -> `center`, `id`) | - |
| `invoice_no` | Business attribute `invoice_no` used by delivery workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `order_no` | Business attribute `order_no` used by delivery workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `delivery_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `shipping_cost` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | No | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | No | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `coment` | Operational field `coment` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `inventory` | Identifier of the related inventory record used by this row. | `int4` | No | No | [inventory](inventory.md) via (`inventory` -> `id`) | - |
| `payment_trans_center` | Center component of the composite reference to the related payment trans record. | `int4` | Yes | No | - | - |
| `payment_trans_id` | Identifier component of the composite reference to the related payment trans record. | `int4` | Yes | No | - | - |
| `payment_trans_subid` | Business attribute `payment_trans_subid` used by delivery workflows and reporting. | `int4` | Yes | No | - | - |
| `paid_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `paid_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `delivery_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (22 query files), [persons](persons.md) (13 query files), [products](products.md) (10 query files), [inventory](inventory.md) (10 query files), [messages](messages.md) (9 query files), [invoice_lines_mt](invoice_lines_mt.md) (9 query files).
- FK-linked tables: outgoing FK to [centers](centers.md), [employees](employees.md), [inventory](inventory.md), [persons](persons.md), [supplier](supplier.md); incoming FK from [delivery_lines_mt](delivery_lines_mt.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [accountingperiods](accountingperiods.md), [advance_notices](advance_notices.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [area_centers](area_centers.md), [attends](attends.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
