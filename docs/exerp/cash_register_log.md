# cash_register_log
Stores historical/log records for cash register events and changes. It is typically used where it appears in approximately 7 query files; common companions include [centers](centers.md), [cashregistertransactions](cashregistertransactions.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `cash_register_center` | Center component of the composite reference to the related cash register record. | `int4` | No | No | [cashregisters](cashregisters.md) via (`cash_register_center`, `cash_register_id` -> `center`, `id`) | - |
| `cash_register_id` | Identifier component of the composite reference to the related cash register record. | `int4` | No | No | [cashregisters](cashregisters.md) via (`cash_register_center`, `cash_register_id` -> `center`, `id`) | - |
| `log_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `reference_global_id` | Identifier for the related reference global entity used by this record. | `text(2147483647)` | Yes | No | - | - |
| `reference_center` | Center component of the composite reference to the related reference record. | `int4` | Yes | No | - | - |
| `reference_id` | Identifier component of the composite reference to the related reference record. | `int4` | Yes | No | - | - |
| `reference_sub_id` | Identifier for the related reference sub entity used by this record. | `int4` | Yes | No | - | - |
| `log_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `event_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | - |
| `receipt` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (7 query files), [cashregistertransactions](cashregistertransactions.md) (6 query files), [employees](employees.md) (6 query files), [persons](persons.md) (6 query files), [area_centers](area_centers.md) (5 query files), [areas](areas.md) (5 query files).
- FK-linked tables: outgoing FK to [cashregisters](cashregisters.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [cashregistertransactions](cashregistertransactions.md), [centers](centers.md), [credit_notes](credit_notes.md), [inventory](inventory.md), [invoices](invoices.md), [vending_machine](vending_machine.md).
