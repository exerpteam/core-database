# licenses
Operational table for licenses records in the Exerp schema. It is typically used where it appears in approximately 50 query files; common companions include [centers](centers.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `center_id` | Identifier of the related centers record used by this row. | `int4` | No | No | [centers](centers.md) via (`center_id` -> `id`) | - |
| `feature` | Operational field `feature` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `start_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `stop_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `contract_id` | Identifier of the related contracts record used by this row. | `int4` | Yes | No | [contracts](contracts.md) via (`contract_id` -> `id`) | - |

# Relations
- Commonly used with: [centers](centers.md) (49 query files), [persons](persons.md) (28 query files), [areas](areas.md) (27 query files), [clipcards](clipcards.md) (27 query files), [questionnaires](questionnaires.md) (27 query files), [area_centers](area_centers.md) (26 query files).
- FK-linked tables: outgoing FK to [centers](centers.md), [contracts](contracts.md); incoming FK from [license_change_logs_content](license_change_logs_content.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bookings](bookings.md), [cashregisters](cashregisters.md), [center_change_logs](center_change_logs.md), [center_ext_attrs](center_ext_attrs.md), [clearinghouse_creditors](clearinghouse_creditors.md), [countries](countries.md), [credit_note_lines_mt](credit_note_lines_mt.md).
