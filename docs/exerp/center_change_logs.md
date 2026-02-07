# center_change_logs
Stores historical/log records for center changes events and changes.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `center_id` | Foreign key field linking this record to `centers`. | `int4` | No | No | [centers](centers.md) via (`center_id` -> `id`) | - |
| `previous_entry_id` | Identifier of the related previous entry record. | `int4` | Yes | No | - | - |
| `change_source` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `change_attribute` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `new_value` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - |
| `employee_center` | Center part of the reference to related employee data. | `int4` | Yes | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) |
| `employee_id` | Identifier of the related employee record. | `int4` | Yes | No | - | - |
| `login_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [centers](centers.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bookings](bookings.md), [cashregisters](cashregisters.md), [center_ext_attrs](center_ext_attrs.md), [clearinghouse_creditors](clearinghouse_creditors.md), [countries](countries.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery](delivery.md).
