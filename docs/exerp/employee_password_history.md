# employee_password_history
Stores historical/log records for employee password events and changes. It is typically used where it appears in approximately 3 query files; common companions include [employees](employees.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `start_date` | Date when the record becomes effective. | `DATE` | No | No | - | - | `2025-01-31` |
| `end_date` | Date when the record ends or expires. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `log_date` | Date for log. | `int8` | No | No | - | - | `42` |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `101` |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `1001` |
| `password` | Text field containing descriptive or reference information. | `VARCHAR(32)` | Yes | No | - | - | `Sample value` |
| `password_hash` | Text field containing descriptive or reference information. | `VARCHAR(65)` | Yes | No | - | - | `Sample value` |
| `password_hash_method` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [employees](employees.md) (3 query files), [persons](persons.md) (3 query files), [employeesroles](employeesroles.md) (2 query files), [roles](roles.md) (2 query files), [bookings](bookings.md) (2 query files), [centers](centers.md) (2 query files).
- FK-linked tables: outgoing FK to [employees](employees.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
- Interesting data points: `start_date` and `end_date` are frequently used for period-window filtering.
