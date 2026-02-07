# licenses
Operational table for licenses records in the Exerp schema. It is typically used where it appears in approximately 50 query files; common companions include [centers](centers.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `center_id` | Foreign key field linking this record to `centers`. | `int4` | No | No | [centers](centers.md) via (`center_id` -> `id`) | - | `1001` |
| `feature` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `start_date` | Date when the record becomes effective. | `DATE` | No | No | - | - | `2025-01-31` |
| `stop_date` | Date for stop. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `contract_id` | Foreign key field linking this record to `contracts`. | `int4` | Yes | No | [contracts](contracts.md) via (`contract_id` -> `id`) | - | `1001` |

# Relations
- Commonly used with: [centers](centers.md) (49 query files), [persons](persons.md) (28 query files), [areas](areas.md) (27 query files), [clipcards](clipcards.md) (27 query files), [questionnaires](questionnaires.md) (27 query files), [area_centers](area_centers.md) (26 query files).
- FK-linked tables: outgoing FK to [centers](centers.md), [contracts](contracts.md); incoming FK from [license_change_logs_content](license_change_logs_content.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bookings](bookings.md), [cashregisters](cashregisters.md), [center_change_logs](center_change_logs.md), [center_ext_attrs](center_ext_attrs.md), [clearinghouse_creditors](clearinghouse_creditors.md), [countries](countries.md), [credit_note_lines_mt](credit_note_lines_mt.md).
