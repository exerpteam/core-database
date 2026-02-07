# exchanged_file_op
Operational table for exchanged file op records in the Exerp schema. It is typically used where it appears in approximately 9 query files; common companions include [exchanged_file](exchanged_file.md), [exchanged_file_exp](exchanged_file_exp.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `exchanged_file_id` | Identifier of the related exchanged file record used by this row. | `int4` | Yes | No | [exchanged_file](exchanged_file.md) via (`exchanged_file_id` -> `id`) | - |
| `start_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `stop_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `operation_id` | Identifier for the related operation entity used by this record. | `text(2147483647)` | Yes | No | - | - |
| `RESULT` | Business attribute `RESULT` used by exchanged file op workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `records` | Operational field `records` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `errors` | Business attribute `errors` used by exchanged file op workflows and reporting. | `int4` | Yes | No | - | - |
| `error_retry` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `error_log` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |

# Relations
- Commonly used with: [exchanged_file](exchanged_file.md) (9 query files), [exchanged_file_exp](exchanged_file_exp.md) (7 query files), [extract](extract.md) (4 query files), [centers](centers.md) (2 query files), [checkins](checkins.md) (2 query files), [companyagreements](companyagreements.md) (2 query files).
- FK-linked tables: outgoing FK to [employees](employees.md), [exchanged_file](exchanged_file.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollection_requests](cashcollection_requests.md).
