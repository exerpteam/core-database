# public_messages
Operational table for public messages records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `version` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `created_at` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `created_by_center` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`created_by_center`, `created_by_id` -> `center`, `id`) | - |
| `created_by_id` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`created_by_center`, `created_by_id` -> `center`, `id`) | - |
| `valid_from` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `valid_to` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `subject` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `body` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `important` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `deleted` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `deleted_at` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `deleted_by_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`deleted_by_center`, `deleted_by_id` -> `center`, `id`) | - |
| `deleted_by_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`deleted_by_center`, `deleted_by_id` -> `center`, `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [employees](employees.md); incoming FK from [public_messages_person](public_messages_person.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
