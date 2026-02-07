# vending_machine
Operational table for vending machine records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 3 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `center` | Identifier of the related centers record used by this row. | `int4` | No | No | [centers](centers.md) via (`center` -> `id`) | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `cash_register_center` | Center component of the composite reference to the related cash register record. | `int4` | No | No | [cashregisters](cashregisters.md) via (`cash_register_center`, `cash_register_id` -> `center`, `id`) | - |
| `cash_register_id` | Identifier component of the composite reference to the related cash register record. | `int4` | No | No | [cashregisters](cashregisters.md) via (`cash_register_center`, `cash_register_id` -> `center`, `id`) | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `reverse_id_rfcard` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `dec_to_hex_id_rfcard` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `operator_id` | Identifier for the related operator entity used by this record. | `text(2147483647)` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [cashregisters](cashregisters.md), [centers](centers.md); incoming FK from [vending_machine_slide](vending_machine_slide.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bookings](bookings.md), [cash_register_log](cash_register_log.md), [cashregistertransactions](cashregistertransactions.md), [center_change_logs](center_change_logs.md), [center_ext_attrs](center_ext_attrs.md), [clearinghouse_creditors](clearinghouse_creditors.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
