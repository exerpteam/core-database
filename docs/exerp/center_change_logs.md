# center_change_logs
Stores historical/log records for center changes events and changes.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `center_id` | Identifier of the related centers record used by this row. | `int4` | No | No | [centers](centers.md) via (`center_id` -> `id`) | - |
| `previous_entry_id` | Identifier for the related previous entry entity used by this record. | `int4` | Yes | No | - | - |
| `change_source` | Business attribute `change_source` used by center change logs workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `change_attribute` | Operational field `change_attribute` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `new_value` | Operational field `new_value` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | - |
| `login_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [centers](centers.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bookings](bookings.md), [cashregisters](cashregisters.md), [center_ext_attrs](center_ext_attrs.md), [clearinghouse_creditors](clearinghouse_creditors.md), [countries](countries.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery](delivery.md).
