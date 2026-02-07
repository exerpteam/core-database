# training_programs
Operational table for training programs records in the Exerp schema. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `101` |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `1001` |
| `creator_center` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`creator_center`, `creator_id` -> `center`, `id`) | - | `101` |
| `creator_id` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`creator_center`, `creator_id` -> `center`, `id`) | - | `1001` |
| `creation_date` | Date for creation. | `DATE` | No | No | - | - | `2025-01-31` |
| `active` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |

# Relations
- FK-linked tables: outgoing FK to [employees](employees.md), [persons](persons.md); incoming FK from [training_program_exercises](training_program_exercises.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [attends](attends.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [booking_program_standby](booking_program_standby.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
