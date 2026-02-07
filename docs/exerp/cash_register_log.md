# cash_register_log
Stores historical/log records for cash register events and changes. It is typically used where it appears in approximately 7 query files; common companions include [centers](centers.md), [cashregistertransactions](cashregistertransactions.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `cash_register_center` | Foreign key field linking this record to `cashregisters`. | `int4` | No | No | [cashregisters](cashregisters.md) via (`cash_register_center`, `cash_register_id` -> `center`, `id`) | - |
| `cash_register_id` | Foreign key field linking this record to `cashregisters`. | `int4` | No | No | [cashregisters](cashregisters.md) via (`cash_register_center`, `cash_register_id` -> `center`, `id`) | - |
| `log_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `reference_global_id` | Identifier of the related reference global record. | `text(2147483647)` | Yes | No | - | - |
| `reference_center` | Center part of the reference to related reference data. | `int4` | Yes | No | - | - |
| `reference_id` | Identifier of the related reference record. | `int4` | Yes | No | - | - |
| `reference_sub_id` | Identifier of the related reference sub record. | `int4` | Yes | No | - | - |
| `log_time` | Epoch timestamp for log. | `int8` | No | No | - | - |
| `event_time` | Epoch timestamp for event. | `int8` | Yes | No | - | - |
| `employee_center` | Center part of the reference to related employee data. | `int4` | Yes | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) |
| `employee_id` | Identifier of the related employee record. | `int4` | Yes | No | - | - |
| `receipt` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (7 query files), [cashregistertransactions](cashregistertransactions.md) (6 query files), [employees](employees.md) (6 query files), [persons](persons.md) (6 query files), [area_centers](area_centers.md) (5 query files), [areas](areas.md) (5 query files).
- FK-linked tables: outgoing FK to [cashregisters](cashregisters.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [cashregistertransactions](cashregistertransactions.md), [centers](centers.md), [credit_notes](credit_notes.md), [inventory](inventory.md), [invoices](invoices.md), [vending_machine](vending_machine.md).
