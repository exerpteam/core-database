# employee_password_history
Stores historical/log records for employee password events and changes. It is typically used where it appears in approximately 3 query files; common companions include [employees](employees.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `start_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `end_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `log_date` | Business date used for scheduling, validity, or reporting cutoffs. | `int8` | No | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `password` | Business attribute `password` used by employee password history workflows and reporting. | `VARCHAR(32)` | Yes | No | - | - |
| `password_hash` | Business attribute `password_hash` used by employee password history workflows and reporting. | `VARCHAR(65)` | Yes | No | - | - |
| `password_hash_method` | Business attribute `password_hash_method` used by employee password history workflows and reporting. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [employees](employees.md) (3 query files), [persons](persons.md) (3 query files), [employeesroles](employeesroles.md) (2 query files), [roles](roles.md) (2 query files), [bookings](bookings.md) (2 query files), [centers](centers.md) (2 query files).
- FK-linked tables: outgoing FK to [employees](employees.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
- Interesting data points: `start_date` and `end_date` are frequently used for period-window filtering.
