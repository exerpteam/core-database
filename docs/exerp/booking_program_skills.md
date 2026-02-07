# booking_program_skills
Operational table for booking program skills records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `booking_program_level_id` | Foreign key field linking this record to `booking_program_levels`. | `int4` | No | No | [booking_program_levels](booking_program_levels.md) via (`booking_program_level_id` -> `id`) | - | `1001` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `rank` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `create_time` | Epoch timestamp for create. | `int8` | No | No | - | - | `1738281600000` |
| `update_time` | Epoch timestamp for update. | `int8` | No | No | - | - | `1738281600000` |
| `update_employee_id` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`update_employee_center`, `update_employee_id` -> `center`, `id`) | - | `1001` |
| `update_employee_center` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`update_employee_center`, `update_employee_id` -> `center`, `id`) | - | `101` |

# Relations
- FK-linked tables: outgoing FK to [booking_program_levels](booking_program_levels.md), [employees](employees.md); incoming FK from [booking_program_person_skills](booking_program_person_skills.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_types](booking_program_types.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md), [cashregisterreports](cashregisterreports.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
