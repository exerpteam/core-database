# exchanged_file_op
Operational table for exchanged file op records in the Exerp schema. It is typically used where it appears in approximately 9 query files; common companions include [exchanged_file](exchanged_file.md), [exchanged_file_exp](exchanged_file_exp.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `exchanged_file_id` | Foreign key field linking this record to `exchanged_file`. | `int4` | Yes | No | [exchanged_file](exchanged_file.md) via (`exchanged_file_id` -> `id`) | - | `1001` |
| `start_time` | Epoch timestamp for start. | `int8` | No | No | - | - | `1738281600000` |
| `stop_time` | Epoch timestamp for stop. | `int8` | No | No | - | - | `1738281600000` |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `101` |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `1001` |
| `operation_id` | Identifier of the related operation record. | `text(2147483647)` | Yes | No | - | - | `1001` |
| `RESULT` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `records` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `errors` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `error_retry` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `error_log` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |

# Relations
- Commonly used with: [exchanged_file](exchanged_file.md) (9 query files), [exchanged_file_exp](exchanged_file_exp.md) (7 query files), [EXTRACT](EXTRACT.md) (4 query files), [centers](centers.md) (2 query files), [checkins](checkins.md) (2 query files), [companyagreements](companyagreements.md) (2 query files).
- FK-linked tables: outgoing FK to [employees](employees.md), [exchanged_file](exchanged_file.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollection_requests](cashcollection_requests.md).
