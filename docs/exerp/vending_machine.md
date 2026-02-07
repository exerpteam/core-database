# vending_machine
Operational table for vending machine records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 3 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `center` | Foreign key field linking this record to `centers`. | `int4` | No | No | [centers](centers.md) via (`center` -> `id`) | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `cash_register_center` | Foreign key field linking this record to `cashregisters`. | `int4` | No | No | [cashregisters](cashregisters.md) via (`cash_register_center`, `cash_register_id` -> `center`, `id`) | - |
| `cash_register_id` | Foreign key field linking this record to `cashregisters`. | `int4` | No | No | [cashregisters](cashregisters.md) via (`cash_register_center`, `cash_register_id` -> `center`, `id`) | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - |
| `reverse_id_rfcard` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `dec_to_hex_id_rfcard` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `operator_id` | Identifier of the related operator record. | `text(2147483647)` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [cashregisters](cashregisters.md), [centers](centers.md); incoming FK from [vending_machine_slide](vending_machine_slide.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bookings](bookings.md), [cash_register_log](cash_register_log.md), [cashregistertransactions](cashregistertransactions.md), [center_change_logs](center_change_logs.md), [center_ext_attrs](center_ext_attrs.md), [clearinghouse_creditors](clearinghouse_creditors.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
