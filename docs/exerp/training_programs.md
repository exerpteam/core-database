# training_programs
Operational table for training programs records in the Exerp schema. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `creator_center` | Center component of the composite reference to the creator staff member. | `int4` | No | No | [employees](employees.md) via (`creator_center`, `creator_id` -> `center`, `id`) | - |
| `creator_id` | Identifier component of the composite reference to the creator staff member. | `int4` | No | No | [employees](employees.md) via (`creator_center`, `creator_id` -> `center`, `id`) | - |
| `creation_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `active` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [employees](employees.md), [persons](persons.md); incoming FK from [training_program_exercises](training_program_exercises.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [attends](attends.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [booking_program_standby](booking_program_standby.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
