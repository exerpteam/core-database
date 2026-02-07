# extract_usage
Operational table for extract usage records in the Exerp schema. It is typically used where it appears in approximately 25 query files; common companions include [EXTRACT](EXTRACT.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `extract_id` | Foreign key field linking this record to `extract`. | `int4` | No | No | [EXTRACT](EXTRACT.md) via (`extract_id` -> `id`) | - |
| `TIME` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `rows_returned` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `time_used` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `source` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |

# Relations
- Commonly used with: [EXTRACT](EXTRACT.md) (25 query files), [persons](persons.md) (13 query files), [employees](employees.md) (10 query files), [centers](centers.md) (4 query files), [extract_group](extract_group.md) (4 query files), [extract_group_link](extract_group_link.md) (4 query files).
- FK-linked tables: outgoing FK to [employees](employees.md), [EXTRACT](EXTRACT.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
