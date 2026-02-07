# report_usage
Operational table for report usage records in the Exerp schema. It is typically used where it appears in approximately 2 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `report_key` | Business attribute `report_key` used by report usage workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `TIME` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | No | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | No | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `rows_returned` | Operational counter/limit used for processing control and performance monitoring. | `int4` | No | No | - | - |
| `time_used` | Operational counter/limit used for processing control and performance monitoring. | `int8` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [employees](employees.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
