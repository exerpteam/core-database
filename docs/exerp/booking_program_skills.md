# booking_program_skills
Operational table for booking program skills records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `booking_program_level_id` | Identifier of the related booking program levels record used by this row. | `int4` | No | No | [booking_program_levels](booking_program_levels.md) via (`booking_program_level_id` -> `id`) | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `rank` | Operational field `rank` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `create_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `update_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `update_employee_id` | Identifier component of the composite reference to the related update employee record. | `int4` | No | No | [employees](employees.md) via (`update_employee_center`, `update_employee_id` -> `center`, `id`) | - |
| `update_employee_center` | Center component of the composite reference to the related update employee record. | `int4` | No | No | [employees](employees.md) via (`update_employee_center`, `update_employee_id` -> `center`, `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [booking_program_levels](booking_program_levels.md), [employees](employees.md); incoming FK from [booking_program_person_skills](booking_program_person_skills.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_types](booking_program_types.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md), [cashregisterreports](cashregisterreports.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
