# booking_program_person_skills
People-related master or relationship table for booking program person skills data.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `booking_program_skill_id` | Identifier of the related booking program skills record used by this row. | `int4` | No | No | [booking_program_skills](booking_program_skills.md) via (`booking_program_skill_id` -> `id`) | - |
| `create_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `update_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `update_employee_id` | Identifier component of the composite reference to the related update employee record. | `int4` | Yes | No | [employees](employees.md) via (`update_employee_center`, `update_employee_id` -> `center`, `id`) | - |
| `update_employee_center` | Center component of the composite reference to the related update employee record. | `int4` | Yes | No | [employees](employees.md) via (`update_employee_center`, `update_employee_id` -> `center`, `id`) | - |
| `comments` | Business attribute `comments` used by booking program person skills workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `create_employee_center` | Center component of the composite reference to the related create employee record. | `int4` | Yes | No | [employees](employees.md) via (`create_employee_center`, `create_employee_id` -> `center`, `id`) | - |
| `create_employee_id` | Identifier component of the composite reference to the related create employee record. | `int4` | Yes | No | [employees](employees.md) via (`create_employee_center`, `create_employee_id` -> `center`, `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [booking_program_skills](booking_program_skills.md), [employees](employees.md), [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [attends](attends.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_levels](booking_program_levels.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md).
